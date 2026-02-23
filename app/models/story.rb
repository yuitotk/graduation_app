class Story < ApplicationRecord
  belongs_to :user
  has_many :story_events, dependent: :destroy
  has_many :story_elements, dependent: :destroy

  # ✅ 追加（このストーリーに「移動してきたアイデア」をぶら下げる）
  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  validates :title, presence: true
end
