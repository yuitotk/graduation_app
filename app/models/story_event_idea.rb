class StoryEventIdea < ApplicationRecord
  belongs_to :story_event

  # 追加ここから
  has_many :story_event_idea_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_idea_elements
  # 追加ここまで

  validates :title, presence: true

  mount_uploader :image, IdeaImageUploader
end
