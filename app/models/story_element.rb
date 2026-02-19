class StoryElement < ApplicationRecord
  belongs_to :story

  enum :kind, { character: 0, item: 1, setting: 2 }

  validates :kind, presence: true
  validates :name, presence: true
end
