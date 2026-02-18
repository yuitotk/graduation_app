class CreateStoryEventIdeas < ActiveRecord::Migration[7.0]
  def change
    create_table :story_event_ideas do |t|
      t.references :story_event, null: false, foreign_key: true
      t.string :title, null: false
      t.text :memo
      t.string :image
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
