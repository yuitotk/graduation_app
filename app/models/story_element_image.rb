class StoryElementImage < ApplicationRecord
  belongs_to :story_element

  mount_uploader :image, IdeaImageUploader
end
