class CreateStoryElementImages < ActiveRecord::Migration[7.0]
  def change
    create_table :story_element_images do |t|
      t.references :story_element, null: false, foreign_key: true
      t.string :image

      t.timestamps
    end
  end
end
