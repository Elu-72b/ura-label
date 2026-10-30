require "test_helper"

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  test "成分詳細に成分名・注意度・配合目的・出典を表示する" do
    get ingredient_path(ingredients(:methylparaben))
    assert_response :success
    assert_select "title", "メチルパラベン | うらラベル"
    assert_select "h1", "メチルパラベン"
    assert_select "dd", text: /3\s*中程度/
    assert_select "dd", text: "防腐剤として配合されることがある"
    assert_select "dd", text: /テスト用データ/
  end

  test "出典がない成分は、出典の記載がないことを表示する" do
    ingredient = ingredients(:water)
    ingredient.update!(source: nil)
    get ingredient_path(ingredient)
    assert_select "dd", text: /出典の記載はありません/
  end

  test "出典URLは http(s) のときだけ、別のタブで開くリンクにする" do
    ingredient = ingredients(:water)
    ingredient.update!(source_url: "https://example.com/source")
    get ingredient_path(ingredient)
    assert_select "a[href=?][target=_blank][rel~=noopener]", "https://example.com/source"

    ingredient.update!(source_url: "javascript:alert(1)")
    get ingredient_path(ingredient)
    assert_select "a[href^=javascript]", 0
  end

  test "AI生成の成分には、AI生成タグと注記を表示する" do
    ingredient = ingredients(:water)
    ingredient.update!(ai_generated: true)
    get ingredient_path(ingredient)
    assert_select "span", "AI生成"
    assert_select "p", text: /誤りを含む可能性があります/
  end

  test "AI生成でない成分には、AI生成タグを表示しない" do
    get ingredient_path(ingredients(:water))
    assert_select "span", text: "AI生成", count: 0
  end

  test "存在しない成分は 404 にする" do
    get ingredient_path(id: 0)
    assert_response :not_found
  end

  test "成分詳細で断定的な言葉を使っていない" do
    get ingredient_path(ingredients(:methylparaben))
    assert_no_forbidden_words
  end
end
