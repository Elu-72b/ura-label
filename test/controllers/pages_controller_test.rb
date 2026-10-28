require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "注意度についてのページを表示する" do
    get caution_path
    assert_response :success
    assert_select "title", "注意度について | うらラベル"
    assert_select "h1", "注意度について"
  end

  test "判定基準の表に、注意度1〜5を数字とラベルで表示する" do
    get caution_path
    assert_select "tbody tr", 5
    assert_select "tbody tr:first-child th", text: /1\s*低め/
    assert_select "tbody tr:last-child th", text: /5\s*高め/
  end

  test "断定的な言葉や効能効果をうたう表現を使っていない" do
    get caution_path
    assert_no_forbidden_words
  end
end
