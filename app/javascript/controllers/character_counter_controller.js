import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]

  connect() {
    this.updateCount()
  }

  updateCount() {
    const currentLength = this.inputTarget.value.length
    const maxLength = this.outputTarget.dataset.maxLength

    this.outputTarget.textContent = `${currentLength} / ${maxLength}文字`
  }
}
