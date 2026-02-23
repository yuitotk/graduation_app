class AddIdeaIdToStoryEventIdeas < ActiveRecord::Migration[7.0]
  def change
    add_reference :story_event_ideas, :idea, foreign_key: true, null: true
  end
end
