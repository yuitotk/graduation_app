class StoryEventIdea < ApplicationRecord
  belongs_to :story_event
  belongs_to :idea, optional: true # ✅ 追加

  has_many :story_event_idea_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_idea_elements

  validates :title, presence: true

  mount_uploader :image, IdeaImageUploader
end
