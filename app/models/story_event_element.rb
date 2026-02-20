class StoryEventElement < ApplicationRecord
  belongs_to :story_event
  belongs_to :story_element

  validates :story_element_id, uniqueness: { scope: :story_event_id }
end
