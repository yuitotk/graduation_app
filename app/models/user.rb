class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password_confirmation

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  has_many :ideas, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :authentications, dependent: :destroy # ✅ 連携しているSNSアカウント（Googleなど）の一覧

  validates :email,
            presence: true,
            length: { maximum: 150 },
            uniqueness: { allow_blank: true },
            format: { with: VALID_EMAIL_REGEX, allow_blank: true }

  validates :password,
            length: { minimum: 8, maximum: 72 },
            if: -> { password.present? }

  # ✅ ゲストログイン用のuserを1件作る。
  #    メールアドレス・パスワードは何も入力させず、本人には見えない仮のメールアドレスを
  #    自動生成して割り当てる（emailはpresence必須なので、これで条件を満たす）。
  #    パスワードは設定しないので、このuserはパスワードではログインできない。
  def self.create_guest!
    create!(email: "guest-#{SecureRandom.hex(12)}@guest.local", guest: true)
  end
end
