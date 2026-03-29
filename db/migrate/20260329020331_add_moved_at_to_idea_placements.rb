class AddMovedAtToIdeaPlacements < ActiveRecord::Migration[7.0]
  def up
    add_column :idea_placements, :moved_at, :datetime

    execute <<~SQL.squish
      UPDATE idea_placements
      SET moved_at = created_at
      WHERE moved_at IS NULL
    SQL

    change_column_null :idea_placements, :moved_at, false
  end

  def down
    remove_column :idea_placements, :moved_at
  end
end
