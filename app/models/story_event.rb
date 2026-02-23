class StoryEvent < ApplicationRecord
  belongs_to :story

  has_many :story_event_ideas, dependent: :destroy

  has_many :story_event_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_elements

  # ✅ 追加（このイベントに「移動してきたアイデア」をぶら下げる）
  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
