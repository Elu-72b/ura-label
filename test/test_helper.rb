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

    # 「用語と表現のルール」で使わない、断定的な言葉
    FORBIDDEN_WORDS = %w[危険 有害 安全 無害].freeze

    # 「用語と表現のルール」で使わない、効能効果をうたう表現(.claude/CLAUDE.md の例)
    # 「防ぐ」だけにすると seed の「酸化を防ぐ」まで引っかかるため、表現のまとまりで書く
    FORBIDDEN_EFFICACY_PHRASES = %w[シミが消える シワが治る ニキビを防ぐ 肌が若返る 美白効果 アンチエイジング 医学的に証明].freeze

    # 文章に、使わない言葉・表現が含まれていないことを確かめる。where はエラーメッセージに出す場所の名前
    def assert_no_forbidden_expressions(text, where)
      (FORBIDDEN_WORDS + FORBIDDEN_EFFICACY_PHRASES).each do |expression|
        assert_not_includes text, expression, "#{where}に「#{expression}」が含まれている"
      end
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # 表示したページのタイトルと本文に、使わない言葉・表現が含まれていないことを確かめる
    def assert_no_forbidden_words
      assert_no_forbidden_expressions(css_select("title, body").map(&:text).join, "画面")
    end
  end
end
