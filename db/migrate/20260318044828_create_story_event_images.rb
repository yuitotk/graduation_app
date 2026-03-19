class CreateStoryEventImages < ActiveRecord::Migration[7.0]
  def change
    create_table :story_event_images do |t|
      t.references :story_event, null: false, foreign_key: true, index: { unique: true }
      t.string :image

      t.timestamps
    end
  end
end
