class CreateStoryImages < ActiveRecord::Migration[7.0]
  def change
    create_table :story_images do |t|
      t.references :story, null: false, foreign_key: true, index: { unique: true }
      t.string :image

      t.timestamps
    end
  end
end
