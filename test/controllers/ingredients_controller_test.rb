require "test_helper"

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  test "成分辞典に、登録済みの成分を五十音順に表示する" do
    get ingredients_path
    assert_response :success
    assert_select "title", "成分辞典 | うらラベル"
    names = css_select("ul.divide-y a span:last-child").map { |span| span.text.strip }
    assert_equal [ "エチルパラベン", "水", "メチルパラベン" ], names
  end

  test "成分辞典の各成分に、注意度の数字つきバッジと詳細へのリンクがある" do
    get ingredients_path
    assert_select "a[href=?][aria-label=?]", ingredient_path(ingredients(:water)), "水(注意度1)", text: /1\s*水/
  end
  test "成分辞典に件数と注意度のタグ、注意度についてへのリンクを表示する" do
    get ingredients_path
    assert_select "p", "3件"
    assert_select "ul li a", text: /5\s*高め/
    assert_select "main a[href=?]", caution_path
  end

  test "成分辞典で断定的な言葉を使っていない" do
    get ingredients_path
    assert_no_forbidden_words
  end

  test "成分辞典を注意度で絞り込める" do
    get ingredients_path, params: { caution_level: [ 1 ] }
    assert_select "p", "1件"
    assert_select "a[href=?]", ingredient_path(ingredients(:water))
    assert_select "span.sr-only", text: "選択中", count: 1
    assert_select "a", text: "条件をクリア"
  end

  test "成分辞典を配合目的の分類で絞り込める" do
    get ingredients_path, params: { category: "防腐" }
    assert_select "p", "2件"
    assert_select "a[href=?]", ingredient_path(ingredients(:water)), 0
  end

  test "注意度と分類を組み合わせて絞り込める" do
    get ingredients_path, params: { caution_level: [ 1 ], category: "防腐" }
    assert_select "p", "0件"
    assert_select "p", "表示できる成分はありません。"
  end

  test "範囲外の注意度や一覧にない分類は、絞り込みなしとして扱う" do
    get ingredients_path, params: { caution_level: [ 9, "abc" ], category: "不明" }
    assert_response :success
    assert_select "p", "3件"
    assert_select "span.sr-only", text: "選択中", count: 0
    assert_select "a", text: "条件をクリア", count: 0
  end

  test "想定外の形式の注意度が送られても、エラーにしない" do
    get ingredients_path, params: { caution_level: { a: "1" } }
    assert_response :success
    assert_select "p", "3件"
  end

  test "注意度が1つの値で送られても、絞り込める" do
    get ingredients_path, params: { caution_level: "1" }
    assert_select "p", "1件"
  end

  test "複数の注意度を選ぶと、どれかに当てはまる成分を表示する" do
    ingredients(:ethylparaben).update!(caution_level: 5)
    get ingredients_path, params: { caution_level: [ 1, 3 ] }
    assert_select "p", "2件"
    assert_select "a[href=?]", ingredient_path(ingredients(:water))
    assert_select "a[href=?]", ingredient_path(ingredients(:methylparaben))
    assert_select "a[href=?]", ingredient_path(ingredients(:ethylparaben)), 0
    assert_select "span.sr-only", text: "選択中", count: 2
  end

  test "注意度タグのリンクは、選択を切り替え、分類の条件を保つ" do
    get ingredients_path, params: { caution_level: [ 1 ], category: "防腐" }
    assert_select "a[href=?]", ingredients_path(category: "防腐")
    assert_select "a[href=?]", ingredients_path(caution_level: [ 1, 3 ], category: "防腐")
  end

  test "分類のフォームは、選択中の注意度を保つ" do
    get ingredients_path, params: { caution_level: [ 1, 3 ] }
    assert_select "form input[type=hidden][name=?][value=?]", "caution_level[]", "1"
    assert_select "form input[type=hidden][name=?][value=?]", "caution_level[]", "3"
  end

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
