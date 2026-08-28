import { Controller } from "@hotwired/stimulus"

// ページ番号を押してTurbo Frame（この欄）の中身が切り替わったときに、
// 欄の先頭が見える位置まで自動でスクロールして戻すためのコントローラー。
// 「turbo:frame-load」は、この欄の中身がページ送りで新しく読み込まれた
// タイミングで発火するイベント。
export default class extends Controller {
  scrollToTop() {
    this.element.scrollIntoView({ block: "start" })
  }
}
