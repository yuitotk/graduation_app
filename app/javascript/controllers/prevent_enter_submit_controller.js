import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  check(event) {
    if (event.key !== "Enter") return

    const tagName = event.target.tagName.toLowerCase()

    if (tagName === "textarea") return

    event.preventDefault()
  }
}
