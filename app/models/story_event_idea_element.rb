class StoryEventIdeaElement < ApplicationRecord
  belongs_to :story_event_idea
  belongs_to :story_element

  validates :story_element_id, uniqueness: { scope: :story_event_idea_id }
end
