# 成分辞典(一覧)と成分詳細
class IngredientsController < ApplicationController
  def index
    # 範囲外の注意度・一覧にない分類は、絞り込みなしとして扱う
    @caution_level = params[:caution_level].to_s.to_i.presence_in(Ingredient::CAUTION_LEVELS)
    @category = params[:category].to_s.presence_in(Ingredient::CATEGORIES)

    @ingredients = Ingredient.order(:reading, :id)
    @ingredients = @ingredients.where(caution_level: @caution_level) if @caution_level
    @ingredients = @ingredients.where(category: @category) if @category
  end

  def show
    @ingredient = Ingredient.find(params[:id])
  end
end
