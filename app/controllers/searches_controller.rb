# 成分入力ページ(トップ)。成分名を1つ入力して、登録済みの成分を探す
class SearchesController < ApplicationController
  # 入力できる文字数の上限(極端に長い入力で検索に時間がかからないようにする)
  MAX_QUERY_LENGTH = 100

  def index
    @query = params[:q].to_s.strip.first(MAX_QUERY_LENGTH)
    @result = IngredientLookup.call(@query) if @query.present?
  end
end
