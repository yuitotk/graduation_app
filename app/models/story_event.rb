class StoryEvent < ApplicationRecord
  belongs_to :story

  has_many :story_event_ideas, dependent: :destroy

  has_many :story_event_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_elements

  has_one :story_event_image, dependent: :destroy
  accepts_nested_attributes_for :story_event_image, update_only: true

  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  before_save :set_text_updated_at, if: :should_update_text_updated_at?

  private

  def should_update_text_updated_at?
    new_record? || will_save_change_to_title? || will_save_change_to_body?
  end

  def set_text_updated_at
    self.text_updated_at = Time.current
  end
end
