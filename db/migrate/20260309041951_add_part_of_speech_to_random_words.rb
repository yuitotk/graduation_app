class AddPartOfSpeechToRandomWords < ActiveRecord::Migration[7.0]
  def change
    add_column :random_words, :part_of_speech, :integer, null: false, default: 0
  end
end
