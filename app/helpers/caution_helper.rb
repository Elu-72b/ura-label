# 注意度(刺激リスクの目安)を画面に表示するためのヘルパー
module CautionHelper
  # 背景色と文字色の組み合わせ。コントラスト比4.5:1以上を目安に、明るい背景には濃い文字色を合わせる
  # Tailwind はクラス名を文字列のまま探すため、"bg-#{color}" のように組み立てず完全な形で書く
  CAUTION_STYLES = {
    1 => "bg-green-700 text-white",
    2 => "bg-lime-300 text-lime-950",
    3 => "bg-yellow-300 text-yellow-950",
    4 => "bg-orange-400 text-orange-950",
    5 => "bg-red-700 text-white"
  }.freeze

  CAUTION_LABELS = { 1 => "低め", 2 => "やや低め", 3 => "中程度", 4 => "やや高め", 5 => "高め" }.freeze

  # 範囲外の注意度は KeyError にする(注意度のない成分に色やラベルを付けない)
  def caution_badge_class(level)
    CAUTION_STYLES.fetch(level)
  end

  def caution_label(level)
    CAUTION_LABELS.fetch(level)
  end
end
