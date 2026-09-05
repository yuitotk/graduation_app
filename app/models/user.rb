class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password_confirmation

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  has_many :ideas, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :authentications, dependent: :destroy # ✅ 連携しているSNSアカウント（Googleなど）の一覧
  has_many :ai_generations, dependent: :destroy # ✅ AI作成を使った記録（ゲストの回数制限に使う）

  # ✅ ゲストが作れるストーリーの件数の上限
  GUEST_STORY_LIMIT = 1
  # ✅ ゲストが1日に使えるAI作成の回数の上限
  GUEST_AI_DAILY_LIMIT = 10

  validates :email,
            presence: true,
            length: { maximum: 150 },
            uniqueness: { allow_blank: true },
            format: { with: VALID_EMAIL_REGEX, allow_blank: true }

  validates :password,
            length: { minimum: 8, maximum: 72 },
            if: -> { password.present? }

  # ✅ 新規登録・ゲスト開始のどちらでも、user作成の直後に見本データ（ストーリー・要素・
  #    イベント・詳細メモ・アイデア）を1人分作る（中身はUsers::SampleContentSeeder）
  after_create :seed_sample_content

  # ✅ ゲストログイン用のuserを1件作る。
  #    メールアドレス・パスワードは何も入力させず、本人には見えない仮のメールアドレスを
  #    自動生成して割り当てる（emailはpresence必須なので、これで条件を満たす）。
  #    パスワードは設定しないので、このuserはパスワードではログインできない。
  def self.create_guest!
    create!(email: "guest-#{SecureRandom.hex(12)}@guest.local", guest: true)
  end

  # ✅ ゲストが、もうストーリーを上限まで作っているか
  #    見本ストーリー（is_sample: true）は、自分で作った件数には数えない
  def guest_story_limit_reached?
    guest? && stories.where(is_sample: false).count >= GUEST_STORY_LIMIT
  end

  # ✅ ゲストが、今日はもうAI作成を上限まで使っているか
  def guest_ai_limit_reached?
    guest? && ai_generations_used_today >= GUEST_AI_DAILY_LIMIT
  end

  # ✅ 今日、あと何回AI作成を使えるか（ゲストでなければnil＝無制限）
  def ai_generations_remaining_today
    return nil unless guest?

    [GUEST_AI_DAILY_LIMIT - ai_generations_used_today, 0].max
  end

  # ✅ あとストーリーを何件作れるか（ゲストでなければnil＝無制限）
  #    見本ストーリー（is_sample: true）は、自分で作った件数には数えない
  def stories_remaining
    return nil unless guest?

    [GUEST_STORY_LIMIT - stories.where(is_sample: false).count, 0].max
  end

  private

  def ai_generations_used_today
    ai_generations.where(created_at: Time.zone.now.beginning_of_day..).count
  end

  def seed_sample_content
    Users::SampleContentSeeder.call(self)
  end
end
