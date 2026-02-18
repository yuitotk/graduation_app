class StoryEventIdea < ApplicationRecord
  belongs_to :story_event

  validates :title, presence: true

  mount_uploader :image, IdeaImageUploader
end
