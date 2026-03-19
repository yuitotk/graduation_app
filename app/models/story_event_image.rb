class StoryEventImage < ApplicationRecord
  belongs_to :story_event

  mount_uploader :image, IdeaImageUploader
end
