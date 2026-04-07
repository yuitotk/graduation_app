class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password_confirmation

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  has_many :ideas, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :stories, dependent: :destroy

  validates :email,
            presence: true,
            length: { maximum: 150 },
            uniqueness: { allow_blank: true },
            format: { with: VALID_EMAIL_REGEX, allow_blank: true }

  validates :password,
            length: { minimum: 8, maximum: 72 },
            if: -> { password.present? }
end
