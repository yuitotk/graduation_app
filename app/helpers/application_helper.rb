module ApplicationHelper
  def story_element_label(element)
    marker = element.marker.presence
    name   = element.name.to_s
    kind   = story_element_kind_label(element)

    main_label = [marker, name].compact.join("　")
    return main_label if kind.blank?

    "#{main_label}（#{kind}）"
  end

  def story_element_short_label(element)
    [element.marker.presence, element.name.to_s].compact.join("　")
  end

  def story_element_kind_label(element)
    return element.kind_i18n if element.respond_to?(:kind_i18n) && element.kind_i18n.present?

    {
      "character" => "キャラクター",
      "item" => "アイテム",
      "setting" => "設定"
    }[element.kind.to_s] || element.kind.to_s.presence
  end
end
