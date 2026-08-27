import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "selectedArea",
    "group",
    "checkbox",
    "summary",
    "emptyMessage"
  ]

  connect() {
    this.refresh()
  }

  toggle(event) {
    const button = event.currentTarget
    const kind = button.dataset.kind
    const group = this.groupTargets.find((element) => element.dataset.kind === kind)
    if (!group) return

    const isHidden = group.hasAttribute("hidden")

    if (isHidden) {
      group.removeAttribute("hidden")
      button.textContent = `▼ ${button.dataset.label}`
      button.setAttribute("aria-expanded", "true")
    } else {
      group.setAttribute("hidden", true)
      button.textContent = `▶ ${button.dataset.label}`
      button.setAttribute("aria-expanded", "false")
    }
  }

  refresh() {
    const selectedByKind = {
      character: [],
      item: [],
      setting: [],
      place: [],
      organization: []
    }

    this.checkboxTargets.forEach((checkbox) => {
      if (!checkbox.checked) return

      selectedByKind[checkbox.dataset.kind] ||= []
      selectedByKind[checkbox.dataset.kind].push({
        id: checkbox.value,
        label: checkbox.dataset.label
      })
    })

    this.summaryTargets.forEach((summary) => {
      const kind = summary.dataset.kind
      const items = selectedByKind[kind] || []

      if (items.length === 0) {
        summary.setAttribute("hidden", true)
        summary.innerHTML = ""
        return
      }

      summary.removeAttribute("hidden")
      summary.innerHTML = `
        <div style="font-weight: bold; margin-bottom: 8px;">
          ${this.kindLabel(kind)}（${items.length}）
        </div>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
          ${items.map((item) => this.badgeHtml(item)).join("")}
        </div>
      `
    })

    if (this.hasEmptyMessageTarget) {
      const hasAnySelected = Object.values(selectedByKind).some((items) => items.length > 0)

      if (hasAnySelected) {
        this.emptyMessageTarget.setAttribute("hidden", true)
      } else {
        this.emptyMessageTarget.removeAttribute("hidden")
      }
    }
  }

  // タグ自体を押すと、対応するチェックボックスのチェックを外して選択解除する
  badgeHtml(item) {
    return `
      <span data-action="click->element-selector#remove"
            data-id="${this.escapeHtml(item.id)}"
            title="クリックで選択解除"
            style="display: inline-flex; align-items: center; gap: 4px; padding: 6px 10px; border: 1px solid #ccc; border-radius: 9999px; cursor: pointer;">
        ${this.escapeHtml(item.label)}
        <span aria-hidden="true" style="color: #f87171; font-weight: bold;">×</span>
      </span>
    `
  }

  remove(event) {
    const id = event.currentTarget.dataset.id
    const checkbox = this.checkboxTargets.find((element) => element.value === id)
    if (!checkbox) return

    checkbox.checked = false
    this.refresh()
  }

  kindLabel(kind) {
    return {
      character: "キャラクター",
      item: "アイテム",
      setting: "設定",
      place: "場所",
      organization: "団体・グループ"
    }[kind] || kind
  }

  escapeHtml(text) {
    return String(text)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
