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
end
