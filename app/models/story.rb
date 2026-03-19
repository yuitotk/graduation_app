class Story < ApplicationRecord
  belongs_to :user
  has_many :story_events, dependent: :destroy
  has_many :story_elements, dependent: :destroy

  has_one :story_image, dependent: :destroy
  accepts_nested_attributes_for :story_image, update_only: true

  # ✅ 追加（このストーリーに「移動してきたアイデア」をぶら下げる）
  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  TITLE_MAX_LENGTH = 40

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
end
