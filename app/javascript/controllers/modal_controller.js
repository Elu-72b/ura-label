import { Controller } from "@hotwired/stimulus";

// 成分詳細のモーダル(スマホではボトムシート)
// 閉じるときは、中身を入れている turbo-frame を空にする
export default class extends Controller {
  static targets = ["closeButton"];

  connect() {
    // 開く前にフォーカスがあった要素(押したバッジ)を覚えておき、閉じたら戻す
    this.previouslyFocused = document.activeElement;
    this.closeButtonTarget.focus();
  }

  close() {
    const frame = this.element.closest("turbo-frame");
    frame.removeAttribute("src");
    frame.innerHTML = "";
    this.previouslyFocused?.focus();
  }
}
