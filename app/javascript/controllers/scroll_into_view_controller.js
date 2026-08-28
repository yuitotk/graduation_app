import { Controller } from "@hotwired/stimulus"

// ページ番号を押してTurbo Frame（この欄）の中身が切り替わったときに、
// 見える位置まで自動でスクロールして戻すためのコントローラー。
// 「turbo:frame-load」は、この欄の中身がページ送りで新しく読み込まれた
// タイミングで発火するイベント。
//
// 通常は欄(Turbo Frame)自体の先頭までスクロールするが、
// 見出しなど「一覧より少し上」まで見せたい場合は、
// data-scroll-into-view-target="anchor" を付けた要素を
// 代わりのスクロール先として使う。
export default class extends Controller {
  static targets = ["anchor"]

  scrollToTop() {
    const target = this.hasAnchorTarget ? this.anchorTarget : this.element
    target.scrollIntoView({ block: "start" })
  }
}
