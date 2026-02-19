class CreateStoryElements < ActiveRecord::Migration[7.0]
  def change
    create_table :story_elements do |t|
      t.references :story, null: false, foreign_key: true
      t.integer :kind
      t.string :name
      t.text :memo

      t.timestamps
    end
  end
end
