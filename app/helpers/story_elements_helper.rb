module StoryElementsHelper
  def story_element_label(element)
    marker = element.marker.presence
    name   = element.name.to_s
    kind   = story_element_kind_label(element)

    [marker, name, kind].compact.join(" ")
  end

  def story_element_kind_label(element)
    # enum を使ってる場合は kind_i18n が生えることが多い
    return element.kind_i18n if element.respond_to?(:kind_i18n) && element.kind_i18n.present?

    # それ以外は kind をそのまま出す（nil/空なら出さない）
    element.kind.to_s.presence
  end
end
