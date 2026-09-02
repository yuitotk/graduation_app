import { Controller } from "@hotwired/stimulus"

// アイコンボタンを押すと、対応する中身だけを表示し、他は隠す
// 汎用的なタブ切り替えコントローラー。
//
// tabTarget: 切り替え用のアイコンボタン（複数）
// panelTarget: ボタンに対応する中身（複数、tabTargetと同じ並び順にする）
//
// 例:
//   <div data-controller="panel-tabs">
//     <button data-panel-tabs-target="tab" data-action="panel-tabs#select" data-panel-tabs-index-param="0">…</button>
//     <button data-panel-tabs-target="tab" data-action="panel-tabs#select" data-panel-tabs-index-param="1">…</button>
//
//     <div data-panel-tabs-target="panel">…0番目の中身…</div>
//     <div data-panel-tabs-target="panel" hidden>…1番目の中身…</div>
//   </div>
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    // 画面を開いた直後、まだ何もクリックしていない状態。
    // HTML側で最初から表示している欄（hidden属性が付いていない欄）に
    // ボタンの見た目（is-active）を合わせておく。
    const initialIndex = this.panelTargets.findIndex((panel) => !panel.hidden)
    this.select({ params: { index: initialIndex === -1 ? 0 : initialIndex } })
  }

  // アイコンボタンを押した直後に呼ばれる
  select(event) {
    const index = event.params.index

    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("is-active", i === index)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.hidden = i !== index
    })
  }
}
