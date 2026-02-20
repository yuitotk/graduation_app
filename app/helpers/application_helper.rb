module ApplicationHelper
  def story_element_label(element)
    [element.marker.presence, element.name].compact.join(" ")
  end
end
