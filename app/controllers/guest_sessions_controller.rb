class GuestSessionsController < ApplicationController
  # 「ゲストとして始める」ボタンを押した直後に呼ばれる。
  # 何も入力させず、その場でゲスト用のuserを作ってそのままログインさせる。
  def create
    user = User.create_guest!
    auto_login(user)
    redirect_to ideas_path, notice: "ゲストとして利用を開始しました"
  end
end
