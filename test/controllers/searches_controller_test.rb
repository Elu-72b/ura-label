require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  test "トップに成分名の入力欄を表示し、入力がなければ結果を出さない" do
    get root_path
    assert_response :success
    assert_select "title", "成分入力 | うらラベル"
    assert_select "form[action=?][method=get] input[type=search][name=q]", root_path
    assert_select "#result-heading", 0
  end

  test "完全に一致した成分は、注意度バッジと配合目的を表示する" do
    get root_path, params: { q: "めちるぱらべん" }
    assert_select "a[href=?]", ingredient_path(ingredients(:methylparaben)), text: /3\s*メチルパラベン/
    assert_select "p", "防腐剤として配合されることがある"
    assert_select "input[name=q][value=?]", "めちるぱらべん"
  end

  test "似ている成分は候補として出し、注意度バッジは出さない" do
    get root_path, params: { q: "メチルパラベソ" }
    assert_select "a[href=?]", root_path(q: "メチルパラベン"), text: "メチルパラベン"
    assert_select "a[href=?]", ingredient_path(ingredients(:methylparaben)), 0
  end

  test "見つからない成分は、注意度を付けずに取得できなかったことを表示する" do
    get root_path, params: { q: "ゾウリムシエキス" }
    assert_select "p", text: /「ゾウリムシエキス」の情報を取得できませんでした/
    assert_select "a[aria-label*=注意度]", 0
  end

  test "入力が長すぎるときは、先頭の100文字で検索する" do
    get root_path, params: { q: "ア" * 200 }
    assert_response :success
    assert_select "input[name=q][value=?]", "ア" * 100
  end

  test "入力にヌル文字が含まれていても、エラーにせず検索する" do
    get root_path, params: { q: "メチル\u0000パラベン" }
    assert_response :success
    assert_select "a[href=?]", ingredient_path(ingredients(:methylparaben))
  end

  test "検索結果で断定的な言葉を使っていない" do
    [ "メチルパラベン", "メチルパラベソ", "ゾウリムシエキス" ].each do |query|
      get root_path, params: { q: query }
      assert_no_forbidden_words
    end
  end
end
