require "test_helper"

# 利用者が入力した内容をログに残さないことを確かめる
class ParameterFilterTest < ActionDispatch::IntegrationTest
  test "検索語はログで隠す" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    assert_equal "[FILTERED]", filter.filter("q" => "メチルパラベン")["q"]
  end

  test "q を含むだけの名前は隠さない" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    assert_equal "1", filter.filter("request" => "1")["request"]
  end
end
