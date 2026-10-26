require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  setup do
    @ingredient = ingredients(:water)
  end

  test "fixture の成分は有効" do
    assert @ingredient.valid?
  end

  test "name が空だと無効" do
    @ingredient.name = ""
    assert_not @ingredient.valid?
    assert @ingredient.errors.of_kind?(:name, :blank)
  end

  test "name が登録済みの成分と同じだと無効" do
    duplicate = @ingredient.dup
    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:name, :taken)
  end

  test "reading が空だと無効" do
    @ingredient.reading = ""
    assert_not @ingredient.valid?
    assert @ingredient.errors.of_kind?(:reading, :blank)
  end

  test "reading にカタカナ以外が含まれると無効" do
    [ "みず", "水", "Water" ].each do |reading|
      @ingredient.reading = reading
      assert_not @ingredient.valid?, "reading=#{reading} が有効になっている"
      assert @ingredient.errors.of_kind?(:reading, :invalid)
    end
  end

  test "reading はカタカナ・長音・中点・数字なら有効" do
    [ "ミズ", "グリセリン", "ピーイージー60", "ビタミンシー・ユウドウタイ" ].each do |reading|
      @ingredient.reading = reading
      assert @ingredient.valid?, "reading=#{reading} が無効になっている"
    end
  end

  test "caution_level が 1 と 5 なら有効" do
    [ 1, 5 ].each do |level|
      @ingredient.caution_level = level
      assert @ingredient.valid?, "caution_level=#{level} が無効になっている"
    end
  end

  test "caution_level が 0・6・空だと無効" do
    [ 0, 6, nil ].each do |level|
      @ingredient.caution_level = level
      assert_not @ingredient.valid?, "caution_level=#{level.inspect} が有効になっている"
      assert @ingredient.errors.of_kind?(:caution_level, :inclusion)
    end
  end

  test "category が一覧にない値や空だと無効" do
    [ "存在しない目的", nil ].each do |category|
      @ingredient.category = category
      assert_not @ingredient.valid?, "category=#{category.inspect} が有効になっている"
      assert @ingredient.errors.of_kind?(:category, :inclusion)
    end
  end

  test "purpose が空だと無効" do
    @ingredient.purpose = ""
    assert_not @ingredient.valid?
    assert @ingredient.errors.of_kind?(:purpose, :blank)
  end

  test "ai_generated が空だと無効" do
    @ingredient.ai_generated = nil
    assert_not @ingredient.valid?
    assert @ingredient.errors.of_kind?(:ai_generated, :inclusion)
  end

  test "バリデーションを飛ばしても、範囲外の注意度は DB のチェック制約で保存できない" do
    assert_raises(ActiveRecord::CheckViolation) do
      @ingredient.update_column(:caution_level, 6)
    end
  end

  test "バリデーションを飛ばしても、空の読みは DB の NOT NULL 制約で保存できない" do
    assert_raises(ActiveRecord::NotNullViolation) do
      @ingredient.update_column(:reading, nil)
    end
  end

  test "バリデーションを飛ばしても、同じ名前は DB のユニークインデックスで保存できない" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      @ingredient.dup.save(validate: false)
    end
  end
end
