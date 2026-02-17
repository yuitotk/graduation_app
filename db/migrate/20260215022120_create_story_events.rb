class CreateStoryEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :story_events do |t|
      t.references :story, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.integer :position, null: false

      t.timestamps
    end

    add_index :story_events, [:story_id, :position]
  end
end
