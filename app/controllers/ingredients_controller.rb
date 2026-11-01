# 成分辞典(一覧)と成分詳細
class IngredientsController < ApplicationController
  def index
    # 範囲外の注意度・一覧にない分類は、絞り込みなしとして扱う
    @caution_levels = selected_caution_levels
    @category = params[:category].to_s.presence_in(Ingredient::CATEGORIES)

    @ingredients = Ingredient.order(:reading, :id)
    @ingredients = @ingredients.where(caution_level: @caution_levels) if @caution_levels.any?
    @ingredients = @ingredients.where(category: @category) if @category
  end

  def show
    @ingredient = Ingredient.find(params[:id])
  end

  # 入力補完の候補(成分入力ページから入力中に呼ばれる)
  def suggestions
    query = params[:q].to_s.delete("\0").strip.first(SearchesController::MAX_QUERY_LENGTH)
    @suggestions = Ingredient.autocomplete(query)
    render layout: false
  end

  # 入力補完の候補(成分入力ページから入力中に呼ばれる)
  def suggestions
    query = params[:q].to_s.delete("\0").strip.first(SearchesController::MAX_QUERY_LENGTH)
    @suggestions = Ingredient.autocomplete(query)
    render layout: false
  end

  private

  # URL の注意度(?caution_level[]=1&caution_level[]=3)から、正しい値だけを小さい順に取り出す
  def selected_caution_levels
    requested = Array.wrap(params[:caution_level]).map { |level| level.to_s.to_i }
    Ingredient::CAUTION_LEVELS.to_a & requested
  end
end
