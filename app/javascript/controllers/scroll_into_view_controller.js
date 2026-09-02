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

    // 自分の中だけでスクロールする領域（例: ストーリー詳細ページの
    // 分割ペイン）の中にいる場合は、その領域の中だけをスクロールし、
    // ページ全体は動かさない。そういう領域が無ければ、
    // これまで通りページ全体をスクロールして戻す。
    const scrollContainer = this.findScrollableAncestor(target)

    if (scrollContainer) {
      const containerRect = scrollContainer.getBoundingClientRect()
      const targetRect = target.getBoundingClientRect()
      scrollContainer.scrollTop += targetRect.top - containerRect.top
    } else {
      target.scrollIntoView({ block: "start" })
    }
  }

  // targetの祖先をたどり、実際にスクロールしている（中身が高さをはみ出している）
  // overflow-y: auto/scroll の要素を探す。無ければ null。
  findScrollableAncestor(target) {
    let node = target.parentElement

    while (node && node !== document.body) {
      const style = window.getComputedStyle(node)
      const scrollable = (style.overflowY === "auto" || style.overflowY === "scroll")

      if (scrollable && node.scrollHeight > node.clientHeight) {
        return node
      }

      node = node.parentElement
    }

    return null
  }
}
