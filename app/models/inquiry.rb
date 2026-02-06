class Inquiry < ApplicationRecord
  belongs_to :user

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
  validates :body,  presence: true, length: { maximum: 2000 }
end
