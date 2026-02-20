class StoryEvent < ApplicationRecord
  belongs_to :story

  has_many :story_event_ideas, dependent: :destroy

  # 追加ここから
  has_many :story_event_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_elements
  # 追加ここまで

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
