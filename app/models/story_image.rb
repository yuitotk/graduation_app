class StoryImage < ApplicationRecord
  belongs_to :story

  mount_uploader :image, IdeaImageUploader
end
