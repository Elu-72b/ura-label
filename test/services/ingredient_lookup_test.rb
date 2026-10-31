require "test_helper"

class IngredientLookupTest < ActiveSupport::TestCase
  test "成分名が完全に一致すれば、その成分を結果にする" do
    result = IngredientLookup.call("メチルパラベン")
    assert_equal :found, result.status
    assert_equal ingredients(:methylparaben), result.ingredient
  end

  test "ひらがなや空白の表記ゆれがあっても、正規化して一致させる" do
    assert_equal ingredients(:methylparaben), IngredientLookup.call(" めちる ぱらべん ").ingredient
  end

  test "読みで一致させる" do
    assert_equal ingredients(:water), IngredientLookup.call("みず").ingredient
  end

  test "INCI名は大文字・小文字を区別せずに一致させる" do
    assert_equal ingredients(:water), IngredientLookup.call("WATER").ingredient
  end

  test "完全に一致しなければ、似ている成分を候補にし、結果にはしない" do
    result = IngredientLookup.call("メチルパラベソ")
    assert_equal :suggestions, result.status
    assert_nil result.ingredient
    assert_equal ingredients(:methylparaben), result.suggestions.first
  end

  test "同じ読みの成分が複数あれば、自動で選ばずに候補にする" do
    Ingredient.create!(name: "テスト用の水", reading: "ミズ", caution_level: 1, category: "その他", purpose: "テスト用")
    result = IngredientLookup.call("みず")
    assert_equal :suggestions, result.status
    assert_nil result.ingredient
    assert_equal 2, result.suggestions.size
  end

  test "候補もなければ見つからないとし、成分を返さない" do
    result = IngredientLookup.call("ゾウリムシエキス")
    assert_equal :not_found, result.status
    assert_nil result.ingredient
    assert_empty result.suggestions
  end

  test "空の入力や SQL として意味のある文字でも、エラーにせず見つからないとする" do
    assert_equal :not_found, IngredientLookup.call("  ").status
    assert_equal :not_found, IngredientLookup.call("'; DROP TABLE ingredients; --").status
    assert_equal 3, Ingredient.count
  end
end
