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
end
