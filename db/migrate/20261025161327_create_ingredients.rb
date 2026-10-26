class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      # 成分名(#19 で正規化してから保存する)
      t.string :name, null: false
      # INCI名(国際的な表示名)。ない成分もあるため任意
      t.string :inci_name
      # 読み(カタカナ)。成分辞典を五十音順に並べるために使う
      t.string :reading, null: false
      # 注意度(刺激リスクの目安)1〜5。根拠を確認せずに値が入らないよう、デフォルトは付けない
      t.integer :caution_level, null: false
      # 目的別の絞り込み用。Ingredient::CATEGORIES から主なものを1つ
      t.string :category, null: false
      # 主な配合目的(文章)
      t.string :purpose, null: false
      t.text :description
      # 出典名・URL・参照日
      t.string :source
      t.string :source_url
      t.date :source_accessed_on
      t.boolean :ai_generated, null: false, default: false

      t.timestamps

      t.check_constraint "caution_level BETWEEN 1 AND 5", name: "ingredients_caution_level_range"
    end
    add_index :ingredients, :name, unique: true
  end
end
