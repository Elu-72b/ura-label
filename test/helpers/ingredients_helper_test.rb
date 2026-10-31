require "test_helper"

class IngredientsHelperTest < ActionView::TestCase
  test "http・https の URL はそのまま返す" do
    assert_equal "https://example.com/source", source_link_url("https://example.com/source")
    assert_equal "http://example.com", source_link_url("http://example.com")
  end

  test "http・https 以外の URL や空の値は nil を返す" do
    assert_nil source_link_url("javascript:alert(1)")
    assert_nil source_link_url("ftp://example.com")
    assert_nil source_link_url("")
    assert_nil source_link_url(nil)
  end

  test "注意度タグのリンク先は、選択していない注意度を小さい順に足す" do
    assert_equal ingredients_path(caution_level: [ 1 ]), caution_filter_path(1, [], nil)
    assert_equal ingredients_path(caution_level: [ 1, 3 ]), caution_filter_path(1, [ 3 ], nil)
  end

  test "注意度タグのリンク先は、選択中の注意度を外し、分類の条件を保つ" do
    assert_equal ingredients_path(caution_level: [ 3 ], category: "防腐"), caution_filter_path(1, [ 1, 3 ], "防腐")
    assert_equal ingredients_path(category: "防腐"), caution_filter_path(1, [ 1 ], "防腐")
    assert_equal ingredients_path, caution_filter_path(1, [ 1 ], nil)
  end
end
