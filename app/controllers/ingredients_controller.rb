# 成分辞典(一覧)と成分詳細
class IngredientsController < ApplicationController
  def show
    @ingredient = Ingredient.find(params[:id])
  end
end
