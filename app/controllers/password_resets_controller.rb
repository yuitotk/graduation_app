class PasswordResetsController < ApplicationController
  def new; end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    return if @user

    redirect_to root_path, alert: t("password_resets.invalid_token")
  end

  def create
    user = User.find_by(email: params[:email])
    user&.deliver_reset_password_instructions!
    redirect_to root_path, notice: t("password_resets.email_sent")
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    unless @user
      redirect_to root_path, alert: t("password_resets.invalid_token")
      return
    end

    if password_confirmation_mismatch?
      flash.now[:alert] = t("password_resets.password_mismatch")
      render :edit
      return
    end

    if @user.update(password_params) # passwordだけ更新
      redirect_to login_path, notice: t("password_resets.updated")
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password)
  end

  def password_confirmation_mismatch?
    params.dig(:user, :password) != params.dig(:user, :password_confirmation)
  end
end
