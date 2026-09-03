class OauthsController < ApplicationController
  # 「Googleでログイン」ボタンを押した直後（まだGoogle側の画面には行っていない状態）
  # → Google側の許可画面へリダイレクトする
  def google
    login_at(:google)
  end

  # Googleの許可画面で「許可する」を押した後、Googleから戻ってきたときに呼ばれる
  def callback
    provider = params[:provider]

    # すでにこのGoogleアカウントで連携済みのuserがいれば、そのままログイン
    user = login_from(provider)
    if user
      redirect_to ideas_path, notice: "ログインしました"
      return
    end

    # ここに来るのは「まだ一度もこのGoogleアカウントでログインしたことがない」場合
    email = @user_hash.dig(:user_info, "email")
    existing_user = email.present? ? User.find_by(email: email) : nil

    if existing_user
      # 同じメールアドレスで、メール・パスワードの通常登録がすでにある場合
      # → 新しいuserは作らず、既存のuserにGoogleアカウントを連携させる
      existing_user.add_provider_to_user(provider, @user_hash[:uid].to_s)
      auto_login(existing_user)
      redirect_to ideas_path, notice: "既存のアカウントとGoogleアカウントを連携してログインしました"
      return
    end

    # 初めてのユーザー → Googleの情報から新規userを作成
    new_user = create_from(provider)
    if new_user&.persisted?
      auto_login(new_user)
      redirect_to ideas_path, notice: "Googleアカウントで登録してログインしました"
    else
      redirect_to login_path, alert: "Googleログインに失敗しました"
    end
  end
end
