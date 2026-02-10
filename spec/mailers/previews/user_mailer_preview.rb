# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def reset_password_email
    user = User.first
    return "Userが0件です。先にユーザーを1件作ってから再アクセスしてください" unless user

    user.update!(
      reset_password_token: user.reset_password_token.presence || SecureRandom.hex(16),
      reset_password_token_expires_at: 1.hour.from_now
    )

    UserMailer.reset_password_email(user)
  end
end
