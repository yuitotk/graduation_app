class GuestSessionsController < ApplicationController
  # 「ゲストとして始める」ボタンを押した直後に呼ばれる。
  # 何も入力させず、その場でゲスト用のuserを作ってそのままログインさせる。
  def create
    # すでに何かしらログイン中（ゲストも含む）なら、新しく作り直さず今のまま進める。
    # （ボタンの連打や、タブを開き直すなどで無意味なゲストが増えるのを防ぐ）
    if logged_in?
      redirect_to ideas_path, notice: "すでにログイン中です"
      return
    end

    user = User.create_guest!
    auto_login(user)
    redirect_to ideas_path, notice: "ゲストとして利用を開始しました"
  end
end
