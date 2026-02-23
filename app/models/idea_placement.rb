class IdeaPlacement < ApplicationRecord
  belongs_to :idea
  belongs_to :placeable, polymorphic: true
end
