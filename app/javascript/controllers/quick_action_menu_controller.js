import { Controller } from "@hotwired/stimulus"

// 画面右下の稲妻ボタン。押すとメニューが開閉し、外側をクリックすると閉じる
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundCloseIfOutside = this.closeIfOutside.bind(this)
    document.addEventListener("click", this.boundCloseIfOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseIfOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.hidden = !this.menuTarget.hidden
  }

  close() {
    this.menuTarget.hidden = true
  }

  closeIfOutside(event) {
    if (this.menuTarget.hidden) return
    if (this.element.contains(event.target)) return

    this.close()
  }
}
