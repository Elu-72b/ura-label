class Ingredient < ApplicationRecord
  # 目的別の絞り込みに使う配合目的。成分ごとに主なものを1つ選ぶ(ほかの目的は purpose の文章に書く)
  CATEGORIES = %w[保湿 防腐 界面活性 香料 着色 紫外線吸収・散乱 増粘・安定化 pH調整 その他].freeze

  # 注意度(刺激リスクの目安)の範囲。DB のチェック制約と同じ範囲にする
  CAUTION_LEVELS = 1..5

  # 読みに使える文字(カタカナ・長音・中点・半角数字)。五十音順に並べるため、ひらがな・漢字・英字は入れない
  READING_FORMAT = /\A[ァ-ヶー・0-9]+\z/

  # 値を代入したときに加え、find_by(name: ...) / where(name: ...) の検索値にも自動で適用される
  normalizes :name, :reading, with: ->(value) { normalize_name(value) }
  normalizes :inci_name, with: ->(value) { normalize_inci_name(value).presence }

  validates :name, presence: true, uniqueness: true
  validates :reading, presence: true, format: { with: READING_FORMAT, allow_blank: true }
  validates :caution_level, inclusion: { in: CAUTION_LEVELS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :purpose, presence: true
  validates :ai_generated, inclusion: { in: [ true, false ] }

  # 成分名・読みの正規化: 全角英数→半角・半角カナ→全角(NFKC)、ひらがな→カタカナ、空白をすべて除去
  def self.normalize_name(str)
    str.to_s.unicode_normalize(:nfkc).tr("ぁ-ゖ", "ァ-ヶ").gsub(/\s+/, "")
  end

  # INCI名の正規化: NFKC のあと、前後の空白を除いて連続する空白を1つにする(英単語の区切りは残す)
  def self.normalize_inci_name(str)
    str.to_s.unicode_normalize(:nfkc).squish
  end
end
