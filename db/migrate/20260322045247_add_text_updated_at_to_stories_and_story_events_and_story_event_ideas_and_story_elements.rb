class AddTextUpdatedAtToStoriesAndStoryEventsAndStoryEventIdeasAndStoryElements < ActiveRecord::Migration[7.0]
  def change
    add_column :stories, :text_updated_at, :datetime
    add_column :story_events, :text_updated_at, :datetime
    add_column :story_event_ideas, :text_updated_at, :datetime
    add_column :story_elements, :text_updated_at, :datetime
  end
end
