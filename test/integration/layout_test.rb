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
end
