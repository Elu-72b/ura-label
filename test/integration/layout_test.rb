require "test_helper"

# 全ページ共通のヘッダー・フッター(レイアウト)のテスト
class LayoutTest < ActionDispatch::IntegrationTest
  test "フッターに免責事項を表示する" do
    get caution_path
    assert_select "footer section h2", "ご利用にあたって"
    assert_select "footer section li", text: /医学的助言ではありません/
  end

  test "免責事項から注意度についてのページへリンクする" do
    get caution_path
    assert_select "footer a[href=?]", caution_path
  end

  test "ヘッダーのメニューボタンに、開閉の状態を伝える属性がある" do
    get caution_path
    assert_select "header button[aria-label=?][aria-expanded=false][aria-controls=site-menu]", "メニュー"
  end

  test "メニューは最初は閉じていて、注意度についてのリンクがある" do
    get caution_path
    assert_select "nav#site-menu[hidden]" do
      assert_select "a[href=?]", caution_path
    end
  end

  test "フッターメニューの今いるページのリンクに aria-current を付ける" do
    get ingredients_path, params: { caution_level: [ 3 ] }
    assert_select "footer nav a[href=?][aria-current=page]", ingredients_path, text: "成分辞典"
  end

  test "ほかのページでは、フッターメニューのリンクに aria-current を付けない" do
    get caution_path
    assert_select "footer nav a[href=?]", ingredients_path
    assert_select "footer nav a[aria-current]", 0
  end

  test "ヘッダーのアプリ名から成分入力ページ(トップ)へ移動できる" do
    get caution_path
    assert_select "header a[href=?]", root_path, text: "うらラベル"
  end

  test "フッターメニューに成分入力があり、トップでは今いるページとして示す" do
    get root_path, params: { q: "水" }
    assert_select "footer nav a[href=?][aria-current=page]", root_path, text: "成分入力"
  end
end
