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

  # 判定基準と例。docs/CAUTION_CRITERIA.md の「判定基準」の表と同じ内容にする(「注意度について」ページの表に使う)
  CAUTION_CRITERIA = {
    1 => { description: "公的リストで懸念の記載がなく、長年広く使用されている基礎成分",
           examples: "水、グリセリン、BG" },
    2 => { description: "一般に刺激性が低いとされるが、ごく稀に刺激・アレルギーの報告がある",
           examples: "ヒアルロン酸Na、スクワラン等の一部" },
    3 => { description: "旧表示指定成分に該当する、または肌質・体質によって刺激やアレルギーの可能性が指摘されている",
           examples: "パラベン類、エタノール" },
    4 => { description: "旧表示指定成分に該当し、かつ刺激・アレルギーの報告が比較的多い",
           examples: "一部の合成香料・着色料" },
    5 => { description: "公的機関(EU等)で配合濃度や用途の制限があり、注意喚起が多い",
           examples: "一部の紫外線吸収剤・防腐剤" }
  }.freeze

  # 範囲外の注意度は KeyError にする(注意度のない成分に色やラベルを付けない)
  def caution_badge_class(level)
    CAUTION_STYLES.fetch(level)
  end

  def caution_label(level)
    CAUTION_LABELS.fetch(level)
  end

  # 判定基準と例を { description:, examples: } で返す
  def caution_criterion(level)
    CAUTION_CRITERIA.fetch(level)
  end
end
