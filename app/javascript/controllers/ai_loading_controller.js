import { Controller } from "@hotwired/stimulus"

// AI生成ボタンを押した瞬間に、結果表示エリアへ「考え中」メッセージを出す。
// 実際の結果（成功/失敗どちらでも）はTurbo Streamが#ai_resultを
// 丸ごと差し替えるので、このメッセージは自動的に消える。
export default class extends Controller {
  static targets = ["result"]

  show() {
    if (!this.hasResultTarget) return

    this.resultTarget.innerHTML =
      '<p style="margin: 0; font-size: 17px; color: #ddd6fe;">AIが考え中です…少々お待ちください。</p>'
  }
}
