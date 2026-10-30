import { Controller } from "@hotwired/stimulus";

// ヘッダーのハンバーガーメニューを開閉する
// 開閉の状態はボタンの aria-expanded で持ち、スクリーンリーダーにも伝える
export default class extends Controller {
  static targets = ["button", "menu"];

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  open() {
    this.menuTarget.hidden = false;
    this.buttonTarget.setAttribute("aria-expanded", "true");
    // 開いたら、メニュー内の最初の項目にフォーカスを移す
    this.menuTarget.querySelector("a, button")?.focus();
  }

  // Esc キー・項目の選択で閉じる。閉じたらボタンにフォーカスを戻す
  close() {
    if (!this.isOpen) return;

    this.hide();
    this.buttonTarget.focus();
  }

  // メニューの外側をクリックしたら閉じる(クリックした場所からフォーカスを動かさない)
  closeOnOutsideClick(event) {
    if (this.isOpen && !this.element.contains(event.target)) this.hide();
  }

  // 閉じるだけ。Turbo がページを保存する前(turbo:before-cache)にも呼び、開いたまま保存されないようにする
  hide() {
    this.menuTarget.hidden = true;
    this.buttonTarget.setAttribute("aria-expanded", "false");
  }

  get isOpen() {
    return this.buttonTarget.getAttribute("aria-expanded") === "true";
  }
}
