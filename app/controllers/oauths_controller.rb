class OauthsController < ApplicationController
  # 「Googleでログイン」ボタンを押した直後（まだGoogle側の画面には行っていない状態）
  # → Google側の許可画面へリダイレクトする
  def google
    login_at(:google)
  end

  # Googleの許可画面で「許可する」を押した後、Googleから戻ってきたときに呼ばれる
  def callback
    provider = params[:provider]

    # すでにログイン中（ゲストなど）に「Googleと連携する」を押した場合
    # → 新しいuserは作らず、今のuserにGoogleアカウントを追加で紐づける
    return connect_provider_to_current_user(provider) if current_user

    # すでにこのGoogleアカウントで連携済みのuserがいれば、そのままログイン
    return login_with_existing_authentication(provider) if login_from(provider)

    # ここに来るのは「まだ一度もこのGoogleアカウントでログインしたことがない」場合
    return connect_to_matching_email_user(provider) if matching_email_user

    register_new_user_from_google(provider)
  end

  private

  def login_with_existing_authentication(_provider)
    redirect_to ideas_path, notice: "ログインしました"
  end

  # 今回Googleから返ってきたメールアドレスと同じメールアドレスの、
  # メール・パスワードで登録済みのuserを探す
  def matching_email_user
    email = @user_hash.dig(:user_info, "email")
    email.present? ? User.find_by(email: email) : nil
  end

  # 同じメールアドレスの既存userがいた場合 → 新しいuserは作らず、そこにGoogleアカウントを連携させる
  def connect_to_matching_email_user(provider)
    matching_email_user.add_provider_to_user(provider, @user_hash[:uid].to_s)
    auto_login(matching_email_user)
    redirect_to ideas_path, notice: "既存のアカウントとGoogleアカウントを連携してログインしました"
  end

  # 初めてのユーザー → Googleの情報から新規userを作成
  def register_new_user_from_google(provider)
    new_user = create_from(provider)
    if new_user&.persisted?
      auto_login(new_user)
      redirect_to ideas_path, notice: "Googleアカウントで登録してログインしました"
    else
      redirect_to login_path, alert: "Googleログインに失敗しました"
    end
  end

  # ログイン中のuser（ゲストなど）に、今回認可されたGoogleアカウントを紐づける
  def connect_provider_to_current_user(provider)
    sorcery_fetch_user_hash(provider)
    uid = @user_hash[:uid].to_s
    owner = user_class.load_from_provider(provider, uid)

    # このGoogleアカウントが、すでに（自分以外の）別のuserと連携済みでないか確認する。
    # 確認せずに連携しようとすると、authentications側のprovider+uidの一意制約に
    # ぶつかってエラーになるため。
    return redirect_to ideas_path, alert: "このGoogleアカウントはすでに別のアカウントと連携されています" if owner && owner != current_user
    return redirect_to ideas_path, notice: "このGoogleアカウントとはすでに連携済みです" if owner == current_user

    current_user.add_provider_to_user(provider, uid)
    upgrade_guest_email_from_google!

    redirect_to ideas_path, notice: "Googleアカウントと連携しました"
  end

  # ゲストの仮メールアドレスのままだと分かりにくいので、Googleのメールアドレスに
  # 置き換えて正式なアカウントにする（すでに他のuserが使っているメールアドレスの
  # 場合は、そのuserのメールアドレスは変更しない＝連携だけ行う）
  def upgrade_guest_email_from_google!
    return unless current_user.guest?

    google_email = @user_hash.dig(:user_info, "email")
    return if google_email.blank? || User.where(email: google_email).any?

    current_user.update(email: google_email, guest: false)
  end
end
