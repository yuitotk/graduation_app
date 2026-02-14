class IdeaImage < ApplicationRecord
  belongs_to :idea

  mount_uploader :image, IdeaImageUploader
end
