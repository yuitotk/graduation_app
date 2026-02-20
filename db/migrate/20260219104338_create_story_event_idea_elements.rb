class CreateStoryEventIdeaElements < ActiveRecord::Migration[7.0]
  def change
    create_table :story_event_idea_elements do |t|
      t.references :story_event_idea, null: false, foreign_key: true
      t.references :story_element, null: false, foreign_key: true

      t.timestamps
    end

    add_index :story_event_idea_elements, [:story_event_idea_id, :story_element_id],
              unique: true, name: "idx_seie_idea_element"
  end
end
