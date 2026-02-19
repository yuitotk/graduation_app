class AddMarkerToStoryElements < ActiveRecord::Migration[7.0]
  def change
    add_column :story_elements, :marker, :string
  end
end
