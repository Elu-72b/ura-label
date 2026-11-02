class Ingredient < ApplicationRecord
  # 目的別の絞り込みに使う配合目的。成分ごとに主なものを1つ選ぶ(ほかの目的は purpose の文章に書く)
  CATEGORIES = %w[保湿 防腐 界面活性 香料 着色 紫外線吸収・散乱 増粘・安定化 pH調整 その他].freeze

  # 注意度(刺激リスクの目安)の範囲。DB のチェック制約と同じ範囲にする
  CAUTION_LEVELS = 1..5

  # 読みに使える文字(カタカナ・長音・中点・半角数字)。五十音順に並べるため、ひらがな・漢字・英字は入れない
  READING_FORMAT = /\A[ァ-ヶー・0-9]+\z/

  # 入力補完に出す候補の上限
  AUTOCOMPLETE_LIMIT = 8

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

  # 表記ゆれに対応するあいまい検索。似ている成分を類似度(score: 0〜1)の高い順に返す
  # 名前・読みは normalize_name、INCI名は normalize_inci_name でそろえた検索語と比べる
  def self.fuzzy_search(query)
    name_query = normalize_name(query)
    return none if name_query.empty?

    binds = { name_query: name_query, inci_query: normalize_inci_name(query) }
    score = sanitize_sql_array([
      "GREATEST(similarity(name, :name_query), similarity(reading, :name_query), similarity(inci_name, :inci_query)) AS score",
      binds
    ])

    select("ingredients.*", score)
      .where("name % :name_query OR reading % :name_query OR inci_name % :inci_query", binds)
      .order("score DESC", :reading)
  end

  # 入力補完の候補。名前・読み・INCI名に入力が含まれる成分を、前方一致を先にして返す
  # 含まれる成分がなければ、あいまい検索で誤字の候補を探す
  def self.autocomplete(query, limit: AUTOCOMPLETE_LIMIT)
    name_query = sanitize_sql_like(normalize_name(query))
    return none if name_query.empty?

    inci_query = sanitize_sql_like(normalize_inci_name(query))
    prefix_first = sanitize_sql_array([
      "CASE WHEN name LIKE :name_prefix OR reading LIKE :name_prefix OR inci_name ILIKE :inci_prefix THEN 0 ELSE 1 END",
      { name_prefix: "#{name_query}%", inci_prefix: "#{inci_query}%" }
    ])

    matches = where("name LIKE :name OR reading LIKE :name OR inci_name ILIKE :inci", name: "%#{name_query}%", inci: "%#{inci_query}%")
      .order(Arel.sql(prefix_first), :reading, :id)
      .limit(limit)
    matches.exists? ? matches : fuzzy_search(query).limit(limit)
  end
end
