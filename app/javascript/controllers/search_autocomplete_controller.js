// app/javascript/controllers/search_autocomplete_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "scope", "withinStory", "storyId", "storyElement", "list"]

  connect() {
    this.timer = null
    this.abortController = null
  }

  disconnect() {
    this.clearTimer()
    this.abortRequest()
  }

  onInput() {
    this.clearTimer()
    this.timer = setTimeout(() => this.fetchSuggestions(), 200)
  }

  clearTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }

  abortRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }

  fetchSuggestions() {
    const q = (this.inputTarget.value || "").trim()
    if (q.length === 0) {
      this.renderEmpty()
      return
    }

    const scope = this.hasScopeTarget ? (this.scopeTarget.value || "all") : "all"
    const withinStory =
      this.hasWithinStoryTarget ? (this.withinStoryTarget.checked ? "1" : "0") : "0"
    const storyId = this.hasStoryIdTarget ? (this.storyIdTarget.value || "") : ""
    const storyElementId = this.hasStoryElementTarget ? (this.storyElementTarget.value || "") : ""

    const url = new URL("/search/suggestions", window.location.origin)
    url.searchParams.set("q", q)
    url.searchParams.set("scope", scope)
    if (withinStory === "1" && storyId) {
      url.searchParams.set("within_story", "1")
      url.searchParams.set("story_id", storyId)
      if (storyElementId) {
        url.searchParams.set("story_element_id", storyElementId)
      }
    }

    this.abortRequest()
    this.abortController = new AbortController()

    fetch(url.toString(), {
      headers: { Accept: "application/json" },
      signal: this.abortController.signal
    })
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        return res.json()
      })
      .then((data) => this.render(data))
      .catch((e) => {
        if (e.name === "AbortError") return
        this.renderEmpty()
      })
  }

  render(data) {
    // data例: {home:["..."], story:["..."], event:["..."], element:["..."]}
    const items = []
    ;[
      ["home", "ホーム未所属"],
      ["story", "ストーリー内"],
      ["event", "イベント内"],
      ["element", "要素内"]
    ].forEach(([key, label]) => {
      ;(data[key] || []).forEach((title) => {
        items.push({ title, label })
      })
    })

    if (items.length === 0) {
      this.renderEmpty()
      return
    }

    const html = items
      .slice(0, 20)
      .map(
        (it) =>
          `<li data-action="mousedown->search-autocomplete#pick" data-title="${this.escape(
            it.title
          )}">${this.escape(it.title)} <small>(${this.escape(it.label)})</small></li>`
      )
      .join("")

    this.listTarget.innerHTML = html
    this.listTarget.hidden = false
  }

  renderEmpty() {
    this.listTarget.innerHTML = ""
    this.listTarget.hidden = true
  }

  pick(e) {
    const title = e.currentTarget.dataset.title
    this.inputTarget.value = title
    this.renderEmpty()
    // Enter検索はユーザーが検索ボタン/Enterで実行する（壊さない）
  }

  escape(str) {
    return String(str)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
