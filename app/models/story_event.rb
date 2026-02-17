class StoryEvent < ApplicationRecord
  belongs_to :story

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
