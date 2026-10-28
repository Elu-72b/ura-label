require "test_helper"

class CautionHelperTest < ActionView::TestCase
  test "注意度1〜5のすべてに色・ラベル・判定基準がある" do
    Ingredient::CAUTION_LEVELS.each do |level|
      assert caution_badge_class(level).present?
      assert caution_label(level).present?
      assert caution_criterion(level)[:description].present?
      assert caution_criterion(level)[:examples].present?
    end
  end

  test "色・ラベル・判定基準は、注意度の範囲と同じ注意度だけを持つ" do
    levels = Ingredient::CAUTION_LEVELS.to_a
    assert_equal levels, CautionHelper::CAUTION_STYLES.keys
    assert_equal levels, CautionHelper::CAUTION_LABELS.keys
    assert_equal levels, CautionHelper::CAUTION_CRITERIA.keys
  end

  test "背景色と文字色をセットで返す" do
    assert_equal "bg-yellow-300 text-yellow-950", caution_badge_class(3)
  end

  test "ラベルは注意度の高さを表す" do
    assert_equal "低め", caution_label(1)
    assert_equal "高め", caution_label(5)
  end

  test "範囲外の注意度や nil はエラーにする" do
    assert_raises(KeyError) { caution_badge_class(0) }
    assert_raises(KeyError) { caution_label(nil) }
    assert_raises(KeyError) { caution_criterion(6) }
  end
end
