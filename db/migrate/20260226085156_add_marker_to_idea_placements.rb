class AddMarkerToIdeaPlacements < ActiveRecord::Migration[7.0]
  def change
    add_column :idea_placements, :marker, :string
  end
end
