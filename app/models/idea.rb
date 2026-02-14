class Idea < ApplicationRecord
  belongs_to :user

  has_one :idea_image, dependent: :destroy
  accepts_nested_attributes_for :idea_image, update_only: true

  validates :title, presence: true
  validates :memo, presence: true
end
