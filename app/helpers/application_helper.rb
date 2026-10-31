module ApplicationHelper
  # フッターメニューのリンク。今いるページのリンクには aria-current="page" を付ける
  # 見た目は aria-current に合わせて太字・下線にし、色だけで示さない
  def footer_nav_link(name, path)
    link_to name, path,
      aria: { current: ("page" if current_page?(path)) },
      class: "inline-block py-2 text-sm text-gray-800 hover:underline aria-[current=page]:font-bold aria-[current=page]:underline"
  end
end
