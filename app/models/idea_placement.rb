class IdeaPlacement < ApplicationRecord
  belongs_to :idea
  belongs_to :placeable, polymorphic: true, optional: true

  has_many :idea_placement_elements, dependent: :destroy
  has_many :story_elements, through: :idea_placement_elements
end
