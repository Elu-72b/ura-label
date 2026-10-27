ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # 「用語と表現のルール」で画面に使わない言葉
    FORBIDDEN_WORDS = %w[危険 有害 安全 無害].freeze

    # 表示したページの本文に、使わない言葉が含まれていないことを確かめる
    def assert_no_forbidden_words
      text = css_select("body").text
      FORBIDDEN_WORDS.each do |word|
        assert_not_includes text, word, "画面に「#{word}」が含まれている"
      end
    end
  end
end
