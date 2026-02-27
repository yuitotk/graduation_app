# app/models/idea_placement_element.rb
class IdeaPlacementElement < ApplicationRecord
  belongs_to :idea_placement
  belongs_to :story_element
end
