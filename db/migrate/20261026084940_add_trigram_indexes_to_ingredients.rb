class AddTrigramIndexesToIngredients < ActiveRecord::Migration[8.1]
  def change
    # 文字列を3文字ずつに区切って似ている度合いを測る拡張。similarity() と % 演算子が使えるようになる
    enable_extension "pg_trgm"

    # あいまい検索用の GIN インデックス(name の完全一致・ユニーク制約は既存の B-tree インデックスが担当)
    add_index :ingredients, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_ingredients_on_name_trgm"
    add_index :ingredients, :reading, using: :gin, opclass: :gin_trgm_ops, name: "index_ingredients_on_reading_trgm"
    add_index :ingredients, :inci_name, using: :gin, opclass: :gin_trgm_ops, name: "index_ingredients_on_inci_name_trgm"
  end
end
