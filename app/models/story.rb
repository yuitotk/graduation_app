class Story < ApplicationRecord
  belongs_to :user
  has_many :story_events, dependent: :destroy
  has_many :story_elements, dependent: :destroy

  has_one :story_image, dependent: :destroy
  accepts_nested_attributes_for :story_image, update_only: true

  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  TITLE_MAX_LENGTH = 40

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }

  before_save :set_text_updated_at, if: :should_update_text_updated_at?

  private

  def should_update_text_updated_at?
    new_record? || will_save_change_to_title? || will_save_change_to_description?
  end

  def set_text_updated_at
    self.text_updated_at = Time.current
  end
end
