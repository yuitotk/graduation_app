import { Controller } from "@hotwired/stimulus"

// フォームを送信（保存）した直後に、保存ボタンの近くへ
// スピナー付きの「保存中です…」を表示する。
// ページ遷移（Turbo Drive）が完了すれば、この表示ごと画面が切り替わるので消える。
export default class extends Controller {
  static targets = ["indicator"]

  show() {
    if (!this.hasIndicatorTarget) return

    this.indicatorTarget.hidden = false
  }
}
