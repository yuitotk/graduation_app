class Story < ApplicationRecord
  belongs_to :user
  has_many :story_events, dependent: :destroy
  has_many :story_elements, dependent: :destroy

  validates :title, presence: true
end
