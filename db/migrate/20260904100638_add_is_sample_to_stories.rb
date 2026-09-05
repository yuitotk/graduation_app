class AddIsSampleToStories < ActiveRecord::Migration[7.0]
  def change
    add_column :stories, :is_sample, :boolean, default: false, null: false
  end
end
