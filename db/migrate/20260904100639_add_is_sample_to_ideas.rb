class AddIsSampleToIdeas < ActiveRecord::Migration[7.0]
  def change
    add_column :ideas, :is_sample, :boolean, default: false, null: false
  end
end
