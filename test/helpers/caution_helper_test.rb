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
  end

  # 注意度の色とラベルを使うパーシャルも、ここで表示して確かめる
  test "注意度バッジに、注意度の数字・成分名・詳細へのリンクがある" do
    water = ingredients(:water)
    render partial: "ingredients/badge", locals: { ingredient: water }
    assert_select "a[href=?][aria-label=?]", ingredient_path(water), "水(注意度1)", text: /1\s*水/
    assert_select "a.bg-green-700"
  end

  test "凡例に、注意度1〜5を数字とラベルで表示し、注意度についてへリンクする" do
    render partial: "shared/caution_legend"
    assert_select "li", 5
    assert_select "li", text: /5\s*高め/
    assert_select "a[href=?]", caution_path
  end
end
