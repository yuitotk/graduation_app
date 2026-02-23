class CreateIdeaPlacements < ActiveRecord::Migration[7.0]
  def change
    create_table :idea_placements do |t|
      t.references :idea, null: false, foreign_key: true, index: { unique: true } # ✅ 1アイデア=1移動先
      t.references :placeable, null: false, polymorphic: true

      t.timestamps
    end
  end
end
