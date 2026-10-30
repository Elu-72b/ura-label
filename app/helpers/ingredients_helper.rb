# 成分の表示に使うヘルパー
module IngredientsHelper
  # 出典URLは http:// か https:// で始まるときだけ返す(それ以外は nil)
  # javascript: などで始まる値をリンクにすると、クリックしたときにスクリプトが動いてしまうため
  def source_link_url(url)
    url if url.to_s.match?(%r{\Ahttps?://}i)
  end
end
