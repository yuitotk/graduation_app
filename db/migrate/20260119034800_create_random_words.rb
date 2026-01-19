class CreateRandomWords < ActiveRecord::Migration[7.0]
  def change
    create_table :random_words do |t|
      t.string :word, null: false

      t.timestamps
    end

    add_index :random_words, :word, unique: true
  end
end
