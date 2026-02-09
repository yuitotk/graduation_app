class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    user&.deliver_reset_password_instructions!
    redirect_to root_path, notice: "メールを送信しました"
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    unless @user
      redirect_to root_path, alert: "リンクが無効または期限切れです"
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    unless @user
      redirect_to root_path, alert: "リンクが無効または期限切れです"
      return
    end

    if params[:user][:password] != params[:user][:password_confirmation]
      flash.now[:alert] = "パスワード確認が一致しません"
      render :edit
      return
    end

    if @user.update(password_params)
      redirect_to login_path, notice: "パスワードを更新しました"
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password)
  end
end
