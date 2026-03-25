class User < ApplicationRecord
  authenticates_with_sorcery!

  attr_accessor :password_confirmation

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  has_many :ideas, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :stories, dependent: :destroy

  validates :email,
            presence: true,
            uniqueness: true,
            length: { maximum: 150 },
            format: { with: VALID_EMAIL_REGEX }

  validates :password,
            length: { minimum: 8, maximum: 72 },
            if: -> { password.present? }
end
