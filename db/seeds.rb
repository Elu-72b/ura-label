# 成分の初期データ。開発・テスト・本番のどの環境でも、何度実行してもよい(登録済みの成分は飛ばす)
# - 注意度は docs/CAUTION_CRITERIA.md で判定する。出典で確認できた成分だけを入れる
# - 表現は「用語と表現のルール」に合わせる(断定しない・効能をうたわない)
# - 登録済みの成分は、ここを直して再実行しても更新されない。直すときは rails console で行う

# 旧表示指定成分の出典。source_accessed_on は実際に出典を確認した日
old_labeling_source = {
  source: "旧表示指定成分(昭和55年厚生省告示)",
  source_accessed_on: Date.new(2026, 10, 26)
}

# 旧表示指定成分で、EU CosIng でも配合の制限を確認した成分の出典
old_labeling_and_cosing_source = {
  source: "旧表示指定成分(昭和55年厚生省告示)、EU CosIng(Annex VI)",
  source_accessed_on: Date.new(2026, 10, 26)
}

ingredients = [
  # 注意度1〜2: 旧表示指定成分ではない基礎成分(注意度の判定基準の表に例として挙がっている成分。出典は記入しない)
  { name: "水", reading: "ミズ", inci_name: "Water", caution_level: 1, category: "その他",
    purpose: "ほかの成分を溶かす溶剤として配合されることがある" },
  { name: "グリセリン", reading: "グリセリン", inci_name: "Glycerin", caution_level: 1, category: "保湿",
    purpose: "保湿剤として配合されることがある" },
  { name: "BG", reading: "ビージー", inci_name: "Butylene Glycol", caution_level: 1, category: "保湿",
    purpose: "保湿剤や、ほかの成分を溶かす溶剤として配合されることがある" },
  { name: "ヒアルロン酸Na", reading: "ヒアルロンサンナトリウム", inci_name: "Sodium Hyaluronate", caution_level: 2, category: "保湿",
    purpose: "保湿剤として配合されることがある" },

  # 注意度3〜5: 旧表示指定成分
  { name: "メチルパラベン", reading: "メチルパラベン", inci_name: "Methylparaben", caution_level: 3, category: "防腐",
    purpose: "防腐剤として配合されることがある", **old_labeling_source },
  { name: "エチルパラベン", reading: "エチルパラベン", inci_name: "Ethylparaben", caution_level: 3, category: "防腐",
    purpose: "防腐剤として配合されることがある", **old_labeling_source },
  { name: "プロピルパラベン", reading: "プロピルパラベン", inci_name: "Propylparaben", caution_level: 3, category: "防腐",
    purpose: "防腐剤として配合されることがある", **old_labeling_source },
  { name: "フェノキシエタノール", reading: "フェノキシエタノール", inci_name: "Phenoxyethanol", caution_level: 3, category: "防腐",
    purpose: "防腐剤として配合されることがある", **old_labeling_source },
  { name: "安息香酸Na", reading: "アンソクコウサンナトリウム", inci_name: "Sodium Benzoate", caution_level: 3, category: "防腐",
    purpose: "防腐剤として配合されることがある", **old_labeling_source },
  { name: "ラウレス硫酸Na", reading: "ラウレスリュウサンナトリウム", inci_name: "Sodium Laureth Sulfate", caution_level: 3, category: "界面活性",
    purpose: "洗浄剤(界面活性剤)として配合されることがある", **old_labeling_source },
  { name: "PG", reading: "ピージー", inci_name: "Propylene Glycol", caution_level: 3, category: "保湿",
    purpose: "保湿剤や、ほかの成分を溶かす溶剤として配合されることがある", **old_labeling_source },
  { name: "BHT", reading: "ビーエイチティー", inci_name: "BHT", caution_level: 3, category: "その他",
    purpose: "製品の酸化を防ぐ酸化防止剤として配合されることがある", **old_labeling_source },
  { name: "TEA", reading: "ティーイーエー", inci_name: "Triethanolamine", caution_level: 3, category: "pH調整",
    purpose: "製品のpHを調整する目的で配合されることがある", **old_labeling_source },
  { name: "セタノール", reading: "セタノール", inci_name: "Cetyl Alcohol", caution_level: 3, category: "増粘・安定化",
    purpose: "製品の粘度を調整したり、乳化を安定させたりする目的で配合されることがある", **old_labeling_source },
  { name: "ラウリル硫酸Na", reading: "ラウリルリュウサンナトリウム", inci_name: "Sodium Lauryl Sulfate", caution_level: 4, category: "界面活性",
    purpose: "洗浄剤(界面活性剤)として配合されることがある", **old_labeling_source },
  { name: "香料", reading: "コウリョウ", inci_name: "Fragrance", caution_level: 4, category: "香料",
    purpose: "製品に香りを付ける目的で配合されることがある", **old_labeling_source },
  { name: "赤202", reading: "アカ202", inci_name: nil, caution_level: 4, category: "着色",
    purpose: "製品に色を付ける目的で配合されることがある", **old_labeling_source },
  { name: "オキシベンゾン-3", reading: "オキシベンゾン3", inci_name: "Benzophenone-3", caution_level: 5, category: "紫外線吸収・散乱",
    purpose: "紫外線吸収剤として配合されることがある", **old_labeling_and_cosing_source }
]

ingredients.each do |attributes|
  Ingredient.find_or_create_by!(name: attributes[:name]) do |ingredient|
    ingredient.assign_attributes(attributes)
  end
end
