import { Controller } from "@hotwired/stimulus";

const DEBOUNCE_MS = 200;

// 成分名の入力補完。入力中の文字から、登録済みの成分名の候補を出す
export default class extends Controller {
  static targets = ["input", "list"];
  static values = { url: String };

  disconnect() {
    this.cancelPending();
  }

  search() {
    this.cancelPending();
    this.timer = setTimeout(() => this.fetchSuggestions(), DEBOUNCE_MS);
  }

  async fetchSuggestions() {
    const query = this.inputTarget.value.trim();
    if (query === "") {
      this.close();
      return;
    }

    const url = new URL(this.urlValue, window.location.origin);
    url.searchParams.set("q", query);
    this.request = new AbortController();

    try {
      const response = await fetch(url, {
        signal: this.request.signal,
        headers: { Accept: "text/html" },
      });
      if (!response.ok) {
        this.close();
        return;
      }
      this.listTarget.innerHTML = await response.text();
      this.activeIndex = -1;
      this.setOpen(this.options.length > 0);
    } catch (error) {
      if (error.name !== "AbortError") this.close();
    }
  }

  navigate(event) {
    if (event.isComposing || this.listTarget.hidden) return;

    if (event.key === "ArrowDown") {
      event.preventDefault();
      this.moveTo(this.activeIndex + 1);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      this.moveTo(this.activeIndex - 1);
    } else if (event.key === "Enter" && this.activeIndex >= 0) {
      event.preventDefault();
      this.choose(this.options[this.activeIndex]);
    } else if (event.key === "Escape") {
      this.close();
    }
  }

  keepFocus(event) {
    event.preventDefault();
  }

  select(event) {
    const option = event.target.closest("[role=option]");
    if (option) this.choose(option);
  }

  close() {
    this.cancelPending();
    this.setOpen(false);
  }

  // 候補を選んだら、その成分名で検索する
  choose(option) {
    this.inputTarget.value = option.dataset.name;
    this.close();
    this.inputTarget.form.requestSubmit();
  }

  moveTo(index) {
    const count = this.options.length;
    this.activeIndex = (index + count) % count;
    this.options.forEach((option, i) =>
      option.setAttribute("aria-selected", String(i === this.activeIndex)),
    );

    const active = this.options[this.activeIndex];
    this.inputTarget.setAttribute("aria-activedescendant", active.id);
    active.scrollIntoView({ block: "nearest" });
  }

  setOpen(open) {
    this.listTarget.hidden = !open;
    this.inputTarget.setAttribute("aria-expanded", String(open));
    this.inputTarget.removeAttribute("aria-activedescendant");
  }

  cancelPending() {
    clearTimeout(this.timer);
    this.request?.abort();
  }

  get options() {
    return Array.from(this.listTarget.querySelectorAll("[role=option]"));
  }
}
