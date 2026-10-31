# 成分の表示に使うヘルパー
module IngredientsHelper
  # 出典URLは http:// か https:// で始まるときだけ返す(それ以外は nil)
  # javascript: などで始まる値をリンクにすると、クリックしたときにスクリプトが動いてしまうため
  def source_link_url(url)
    url if url.to_s.match?(%r{\Ahttps?://}i)
  end

  # 注意度タグのリンク先。押した注意度を、選択中なら外し、そうでなければ足す。分類の条件は保つ
  def caution_filter_path(level, selected_levels, category)
    levels = selected_levels.include?(level) ? selected_levels - [ level ] : (selected_levels + [ level ]).sort
    ingredients_path(caution_level: levels.presence, category: category)
  end
end
