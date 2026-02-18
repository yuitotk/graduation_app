class StoryEvent < ApplicationRecord
  belongs_to :story

  has_many :story_event_ideas, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
