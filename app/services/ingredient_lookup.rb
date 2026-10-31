# 入力された成分名から、登録済みの成分を探す
#
# 1. 名前・読み・INCI名のどれかが1つの成分と完全に一致すれば、その成分を結果にする(表記ゆれは正規化してから比べる)
# 2. 一致しなければ、あいまい検索で似ている成分を「もしかして」の候補にする
#    類似度だけでは誤字と別の成分を区別できないため、候補を自動で結果にはしない
# 3. 候補もなければ「見つからない」とし、注意度は付けない
class IngredientLookup
  # 「もしかして」に出す候補の上限
  SUGGESTION_LIMIT = 5

  # status は :found(見つかった) / :suggestions(候補のみ) / :not_found(見つからない) のどれか
  Result = Data.define(:query, :status, :ingredient, :suggestions)

  def self.call(query)
    new(query).call
  end

  def initialize(query)
    @query = query.to_s.strip
  end

  def call
    matches = exact_matches.to_a
    return result(:found, ingredient: matches.first) if matches.one?
    return result(:suggestions, suggestions: matches) if matches.many?

    suggestions = Ingredient.fuzzy_search(@query).limit(SUGGESTION_LIMIT).to_a
    return result(:suggestions, suggestions: suggestions) if suggestions.any?

    result(:not_found)
  end

  private

  # where(name: ...) と where(reading: ...) には、モデルの normalizes で正規化した値が使われる
  # INCI名は大文字・小文字を区別せずに比べる("water" でも "Water" を見つける)
  def exact_matches
    return Ingredient.none if @query.empty?

    Ingredient.where(name: @query)
      .or(Ingredient.where(reading: @query))
      .or(Ingredient.where("LOWER(inci_name) = LOWER(?)", Ingredient.normalize_inci_name(@query)))
      .order(:reading, :id)
  end

  def result(status, ingredient: nil, suggestions: [])
    Result.new(query: @query, status: status, ingredient: ingredient, suggestions: suggestions)
  end
end
