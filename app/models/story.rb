class Story < ApplicationRecord
  belongs_to :user
  has_many :story_events, dependent: :destroy

  validates :title, presence: true
end
