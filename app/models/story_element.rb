class StoryElement < ApplicationRecord
  belongs_to :story

  has_one :story_element_image, dependent: :destroy

  has_many :story_event_elements, dependent: :destroy
  has_many :story_events, through: :story_event_elements

  has_many :story_event_idea_elements, dependent: :destroy
  has_many :story_event_ideas, through: :story_event_idea_elements

  has_many :idea_placement_elements, dependent: :destroy
  has_many :linked_idea_placements, through: :idea_placement_elements, source: :idea_placement

  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  accepts_nested_attributes_for :story_element_image, allow_destroy: true

  enum :kind, { character: 0, item: 1, setting: 2 }

  validates :kind, presence: true
  validates :name, presence: true

  before_save :set_text_updated_at, if: :should_update_text_updated_at?

  private

  def should_update_text_updated_at?
    new_record? || will_save_change_to_marker? || will_save_change_to_name? || will_save_change_to_memo?
  end

  def set_text_updated_at
    self.text_updated_at = Time.current
  end
end
