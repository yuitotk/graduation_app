class StoryEventIdea < ApplicationRecord
  belongs_to :story_event
  belongs_to :idea, optional: true

  has_many :story_event_idea_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_idea_elements

  validates :title, presence: true

  mount_uploader :image, IdeaImageUploader

  before_save :set_text_updated_at, if: :should_update_text_updated_at?

  private

  def should_update_text_updated_at?
    new_record? || will_save_change_to_title? || will_save_change_to_memo?
  end

  def set_text_updated_at
    self.text_updated_at = Time.current
  end
end
