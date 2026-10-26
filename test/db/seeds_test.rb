require "test_helper"

# db/seeds.rb を読み込んで、初期データが登録できることを確かめる
# (GitHub Actions の CI は db:seed を実行しないため、テストで確かめる)
class SeedsTest < ActiveSupport::TestCase
  # seed の成分の件数。seed の成分を増やしたり減らしたりしたら、ここも変える
  SEED_COUNT = 18

  # 「用語と表現のルール」で使わない言葉
  FORBIDDEN_WORDS = %w[危険 有害 安全 無害].freeze

  setup do
    # fixture と同じ名前の成分があると、find_or_create_by! が既存の行を使い、seed の値を検証できないため消す
    # (テストごとのトランザクションの中なので、テストが終われば元に戻る)
    Ingredient.delete_all
  end

  test "seed を読み込むと、すべての成分が登録される" do
    assert_difference("Ingredient.count", SEED_COUNT) { Rails.application.load_seed }
  end

  test "seed を2回読み込んでも、成分が重複しない" do
    Rails.application.load_seed
    assert_no_difference("Ingredient.count") { Rails.application.load_seed }
  end

  test "旧表示指定成分の注意度は3以上" do
    Rails.application.load_seed
    low_caution = Ingredient.where("source LIKE ?", "旧表示指定成分%").where(caution_level: ..2)
    assert_empty low_caution.pluck(:name)
  end

  test "配合目的・説明に断定的な言葉を使っていない" do
    Rails.application.load_seed
    Ingredient.find_each do |ingredient|
      text = [ ingredient.purpose, ingredient.description ].compact.join
      FORBIDDEN_WORDS.each do |word|
        assert_not_includes text, word, "#{ingredient.name} の説明に「#{word}」が含まれている"
      end
    end
  end
end
