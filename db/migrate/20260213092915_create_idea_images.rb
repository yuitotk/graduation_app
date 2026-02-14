class CreateIdeaImages < ActiveRecord::Migration[7.0]
  def change
    create_table :idea_images do |t|
      t.references :idea, null: false, foreign_key: true, index: { unique: true }
      t.string :image

      t.timestamps
    end
  end
end
