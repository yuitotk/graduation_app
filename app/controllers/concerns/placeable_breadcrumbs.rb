# frozen_string_literal: true

# 「アイデアの配置先（ストーリー／イベント／要素／イベント詳細メモ）」に応じて
# パンくずリストの中身を組み立てる処理をまとめたconcern。
#
# もともとAiGenerationsController・RandomWordsController・IdeasControllerの
# 3つに、ほぼ同じ内容のprivateメソッドが重複していたため、ここに集約した。
# 挙動は移動前と変えていない（story_element_breadcrumbsに渡す
# breadcrumb_paramsだけ、各controllerの呼び出し側で組み立てて渡すようにした）。
# rubocop:disable Metrics/ModuleLength
module PlaceableBreadcrumbs
  extend ActiveSupport::Concern

  private

  def find_placeable_for_current_user(type, id)
    case type.to_s
    when "Story"
      current_user.stories.find_by(id: id)
    when "StoryEvent"
      StoryEvent.joins(:story).where(stories: { user_id: current_user.id }).find_by(id: id)
    when "StoryElement"
      StoryElement.joins(:story).where(stories: { user_id: current_user.id }).find_by(id: id)
    when "StoryEventIdea"
      StoryEventIdea.joins(story_event: :story).where(stories: { user_id: current_user.id }).find_by(id: id)
    end
  end

  def breadcrumb_items_for_placeable(placeable, breadcrumb_params = {})
    case placeable
    when Story
      story_breadcrumbs(placeable)
    when StoryEvent
      story_event_breadcrumbs(placeable)
    when StoryEventIdea
      story_event_idea_breadcrumbs(placeable)
    when StoryElement
      story_element_breadcrumbs(placeable, breadcrumb_params)
    else
      []
    end
  end

  def story_breadcrumbs(story)
    [
      { name: story.title, path: nil }
    ]
  end

  def story_event_breadcrumbs(story_event)
    story = story_event.story
    [
      { name: story.title, path: story_path(story) },
      { name: story_event.title, path: nil }
    ]
  end

  def story_event_idea_breadcrumbs(story_event_idea)
    story_event = story_event_idea.story_event
    story = story_event.story

    [
      { name: story.title, path: story_path(story) },
      { name: story_event.title, path: story_story_event_path(story, story_event) },
      { name: story_event_idea.title, path: nil }
    ]
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
  def story_element_breadcrumbs(story_element, breadcrumb_params = {})
    story = story_element.story

    case breadcrumb_params[:from]
    when "story_event_idea"
      story_event = story.story_events.find_by(id: breadcrumb_params[:story_event_id])
      story_event_idea = story_event&.story_event_ideas&.find_by(id: breadcrumb_params[:story_event_idea_id])

      if story_event.present? && story_event_idea.present?
        [
          { name: story.title, path: story_path(story) },
          { name: story_event.title, path: story_story_event_path(story, story_event) },
          {
            name: story_event_idea.title,
            path: story_story_event_story_event_idea_path(story, story_event, story_event_idea)
          },
          { name: "要素一覧", path: story_story_elements_path(story, breadcrumb_params) },
          { name: story_element.name, path: nil }
        ]
      else
        [
          { name: story.title, path: story_path(story) },
          { name: "要素一覧", path: story_story_elements_path(story) },
          { name: story_element.name, path: nil }
        ]
      end
    when "story_event"
      story_event = story.story_events.find_by(id: breadcrumb_params[:story_event_id])

      if story_event.present?
        [
          { name: story.title, path: story_path(story) },
          { name: story_event.title, path: story_story_event_path(story, story_event) },
          { name: "要素一覧", path: story_story_elements_path(story, breadcrumb_params) },
          { name: story_element.name, path: nil }
        ]
      else
        [
          { name: story.title, path: story_path(story) },
          { name: "要素一覧", path: story_story_elements_path(story) },
          { name: story_element.name, path: nil }
        ]
      end
    else
      [
        { name: story.title, path: story_path(story) },
        { name: "要素一覧", path: story_story_elements_path(story) },
        { name: story_element.name, path: nil }
      ]
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

  def return_to_breadcrumb_params
    return {} if params[:return_to].blank?

    query = URI.parse(params[:return_to]).query
    return {} if query.blank?

    parsed = Rack::Utils.parse_nested_query(query)

    {
      from: parsed["from"],
      story_event_id: parsed["story_event_id"],
      story_event_idea_id: parsed["story_event_idea_id"]
    }.compact.symbolize_keys
  rescue URI::InvalidURIError
    {}
  end
end
# rubocop:enable Metrics/ModuleLength
