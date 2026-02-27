class CreateIdeaPlacementElements < ActiveRecord::Migration[7.0]
  def change
    create_table :idea_placement_elements do |t|
      t.references :idea_placement, null: false, foreign_key: true
      t.references :story_element,  null: false, foreign_key: true

      t.timestamps
    end

    add_index :idea_placement_elements,
              %i[idea_placement_id story_element_id],
              unique: true,
              name: "idx_ipe_placement_element"
  end
end
