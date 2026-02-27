class AddCreatedHereToIdeaPlacements < ActiveRecord::Migration[7.0]
  def change
    add_column :idea_placements, :created_here, :boolean, null: false, default: false
  end
end
