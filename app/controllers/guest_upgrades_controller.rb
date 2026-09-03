class GuestUpgradesController < ApplicationController
  before_action :require_login
  before_action :require_guest

  # ログイン中のゲストが、正式なメールアドレス・パスワードを設定する画面
  def edit
    @user = current_user
  end

  # ここで初めて、ゲストの仮メールアドレスを本物のメールアドレスに置き換え、
  # パスワードを設定して、正式なアカウント（guest: false）にする。
  def update
    @user = current_user

    if guest_upgrade_params[:password].blank?
      @user.errors.add(:password, "を入力してください")
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(guest_upgrade_params.merge(guest: false))
      redirect_to ideas_path, notice: "正式なアカウントとして登録しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # ゲスト以外（すでに正式登録済み・Googleログイン済みなど）がこの画面に来ても
  # 意味が無いので、アイデア一覧に戻す
  def require_guest
    redirect_to ideas_path, alert: "この操作はゲストのみ利用できます" unless current_user.guest?
  end

  def guest_upgrade_params
    params.require(:user).permit(:email, :password)
  end
end
