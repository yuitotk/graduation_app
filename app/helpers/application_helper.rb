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
      "setting" => "設定",
      "place" => "場所",
      "organization" => "団体・グループ"
    }[element.kind.to_s] || element.kind.to_s.presence
  end

  # フローティングボタン（稲妻マーク）から呼び出せる操作の一覧を返す。
  # ページごとに中身が違い、対象外のページではnilを返す（ボタン自体を表示しない）。
  # リンク先は、それぞれのページに元々ある「新規作成」「AI作成」等のボタンと
  # 完全に同じURL・パラメータにしている（新しい処理を増やさないため）。
  # ヘルパー内でインスタンス変数を直接読まないよう、呼び出し元(view)から
  # story:/story_event:/story_event_idea:/story_element: を渡してもらう。
  def quick_action_menu_items(story: nil, story_event: nil, story_event_idea: nil, story_element: nil)
    case [controller_name, action_name]
    when %w[ideas index]
      home_quick_action_items
    when %w[story_elements show]
      story_element_show_quick_action_items(story_element)
    when %w[stories show]
      story_show_quick_action_items(story)
    when %w[story_events show]
      story_event_show_quick_action_items(story, story_event)
    when %w[story_event_ideas show]
      story_event_idea_show_quick_action_items(story, story_event, story_event_idea)
    end
  end

  private

  def home_quick_action_items
    [
      { label: "アイデア作成", url: new_idea_path },
      { label: "AI作成", url: random_words_pick_path }
    ]
  end

  def story_element_show_quick_action_items(story_element)
    return nil if story_element.blank?

    [
      { label: "アイデア作成",
        url: new_idea_path(return_to: request.fullpath, placeable_type: "StoryElement", placeable_id: story_element.id) },
      { label: "AI作成",
        url: random_words_pick_path(return_to: request.fullpath, placeable_type: "StoryElement",
                                    placeable_id: story_element.id) }
    ]
  end

  def story_show_quick_action_items(story)
    return nil if story.blank?

    [
      { label: "アイデア作成",
        url: new_idea_path(return_to: request.fullpath, placeable_type: "Story", placeable_id: story.id) },
      { label: "AI作成",
        url: random_words_pick_path(return_to: request.fullpath, placeable_type: "Story", placeable_id: story.id) },
      { label: "要素管理", url: story_story_elements_path(story, from: "story") },
      { label: "整合性チェック", url: consistency_story_path(story, from: "story") },
      { label: "イベント追加", url: new_story_story_event_path(story) }
    ]
  end

  def story_event_show_quick_action_items(story, story_event)
    return nil if story.blank? || story_event.blank?

    [
      { label: "アイデア作成",
        url: new_idea_path(return_to: request.fullpath, placeable_type: "StoryEvent", placeable_id: story_event.id) },
      { label: "AI作成",
        url: random_words_pick_path(return_to: request.fullpath, placeable_type: "StoryEvent",
                                    placeable_id: story_event.id) },
      { label: "要素管理",
        url: story_story_elements_path(story, from: "story_event", story_event_id: story_event.id) },
      { label: "整合性チェック",
        url: consistency_story_path(story, from: "story_event", story_event_id: story_event.id) },
      { label: "詳細メモ追加", url: new_story_story_event_story_event_idea_path(story, story_event) }
    ]
  end

  def story_event_idea_show_quick_action_items(story, story_event, story_event_idea)
    return nil if story.blank? || story_event.blank? || story_event_idea.blank?

    context_params = {
      from: "story_event_idea",
      story_event_id: story_event.id,
      story_event_idea_id: story_event_idea.id
    }

    [
      { label: "アイデア作成",
        url: new_idea_path(return_to: request.fullpath, placeable_type: "StoryEventIdea",
                           placeable_id: story_event_idea.id) },
      { label: "AI作成",
        url: random_words_pick_path(return_to: request.fullpath, placeable_type: "StoryEventIdea",
                                    placeable_id: story_event_idea.id) },
      { label: "要素管理", url: story_story_elements_path(story, context_params) },
      { label: "整合性チェック", url: consistency_story_path(story, context_params) }
    ]
  end
end
