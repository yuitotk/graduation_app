# app/controllers/search_controller.rb
# rubocop:disable Metrics/ClassLength
class SearchController < ApplicationController
  before_action :require_login

  def index
    prepare_search_context_for_index
    store_search_return_to
    sync_search_story_session(within_story: @within_story, story_id: @story_id)
    set_search_breadcrumb_context
    @results = perform_search
  end

  def suggestions
    q = params[:q].to_s.strip
    return render(json: {}) if q.blank?

    scope, within_story, story_id, story_element_id = prepare_search_context_for_suggestions

    service_story_id = within_story ? story_id : nil
    service_story_element_id = within_story ? story_element_id : nil

    suggestions =
      Search::Suggestions.new(
        q: q,
        scope: scope,
        story_id: service_story_id,
        story_element_id: service_story_element_id,
        user: current_user
      ).call

    render json: suggestions
  end

  private

  def prepare_search_context_for_index
    assign_search_params_for_index
    assign_story_for_index
    assign_story_event_for_index
    assign_story_event_idea_for_index
    assign_story_element_for_index
    assign_page_context_for_index
  end

  def assign_search_params_for_index
    @query = params[:q].to_s.strip
    @scope = normalize_scope(params[:scope])
    @within_story = params[:within_story].to_s == "1"
    @story_id = params[:story_id].presence&.to_i

    resolved_context = resolved_search_context_from_params_or_return_to
    @from = resolved_context[:from]
    @context_story_event_id = resolved_context[:story_event_id]
    @context_story_event_idea_id = resolved_context[:story_event_idea_id]
    @page_type = normalized_page_type(params[:page_type])
    @page_id = params[:page_id].presence&.to_i
  end

  def assign_story_for_index
    @story = current_user.stories.find_by(id: @story_id) if @within_story && @story_id
  end

  def assign_story_event_for_index
    return if @story.blank?
    return unless %w[story_event story_event_idea].include?(@from)
    return if @context_story_event_id.blank?

    @context_story_event = @story.story_events.find_by(id: @context_story_event_id)
  end

  def assign_story_event_idea_for_index
    return if @story.blank?
    return unless @from == "story_event_idea"
    return if @context_story_event.blank?
    return if @context_story_event_idea_id.blank?

    @context_story_event_idea =
      @context_story_event.story_event_ideas.find_by(id: @context_story_event_idea_id)
  end

  def assign_story_element_for_index
    raw_story_element_id = params[:story_element_id].presence&.to_i

    @story_element_id =
      sanitize_story_element_id(
        story: @story,
        within_story: @within_story,
        story_element_id: raw_story_element_id
      )

    return unless @story.present? && @story_element_id.present?

    @selected_story_element = @story.story_elements.find_by(id: @story_element_id)
  end

  def assign_page_context_for_index
    return if @story.blank?
    return unless @page_type == "story_element"
    return if @page_id.blank?

    @page_story_element = @story.story_elements.find_by(id: @page_id)
  end

  def prepare_search_context_for_suggestions
    scope = normalize_scope(params[:scope])
    within_story = params[:within_story].to_s == "1"
    story_id = params[:story_id].presence&.to_i

    story = current_user.stories.find_by(id: story_id) if within_story && story_id

    raw_story_element_id = params[:story_element_id].presence&.to_i
    story_element_id =
      sanitize_story_element_id(
        story: story,
        within_story: within_story,
        story_element_id: raw_story_element_id
      )

    [scope, within_story, story_id, story_element_id]
  end

  def sanitize_story_element_id(story:, within_story:, story_element_id:)
    return nil unless within_story
    return nil if story.blank?
    return nil if story_element_id.blank?
    return story_element_id if story.story_elements.exists?(id: story_element_id)

    nil
  end

  def store_search_return_to
    rt = safe_path(params[:return_to])
    session[:search_return_to] = rt if rt.present? && !rt.start_with?("/search")
  end

  def perform_search
    return {} if @query.blank? && @story_element_id.blank?

    service_story_id = @within_story ? @story_id : nil
    service_story_element_id = @within_story ? @story_element_id : nil

    Search::Query.new(
      q: @query,
      scope: @scope,
      story_id: service_story_id,
      story_element_id: service_story_element_id,
      user: current_user
    ).call
  end

  def set_search_breadcrumb_context
    @search_breadcrumb_params = search_breadcrumb_params
    @search_breadcrumb_items = build_search_breadcrumb_items
  end

  def build_search_breadcrumb_items
    case @page_type
    when "story_element"
      build_story_element_page_search_breadcrumbs
    when "story_elements_index"
      build_story_elements_index_search_breadcrumbs
    when "consistency"
      build_consistency_search_breadcrumbs
    when "story_event_idea"
      build_story_event_idea_search_breadcrumbs
    when "story_event"
      build_story_event_search_breadcrumbs
    else
      build_story_search_breadcrumbs
    end
  end

  def build_story_search_breadcrumbs
    return default_search_breadcrumbs if @story.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_search_breadcrumbs
    return build_story_search_breadcrumbs if @story.blank? || @context_story_event.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_idea_search_breadcrumbs
    return build_story_event_search_breadcrumbs if @story.blank? || @context_story_event.blank? || @context_story_event_idea.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: @context_story_event_idea.title,
        path: story_story_event_story_event_idea_path(
          @story,
          @context_story_event,
          @context_story_event_idea,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_elements_index_search_breadcrumbs
    return build_story_event_idea_search_breadcrumbs_with_elements_index if @from == "story_event_idea"
    return build_story_event_search_breadcrumbs_with_elements_index if @from == "story_event"

    return build_story_search_breadcrumbs if @story.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: "要素一覧",
        path: story_story_elements_path(@story, from: "story")
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_search_breadcrumbs_with_elements_index
    return build_story_search_breadcrumbs if @story.blank? || @context_story_event.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: "要素一覧",
        path: story_story_elements_path(
          @story,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_idea_search_breadcrumbs_with_elements_index
    return build_story_event_search_breadcrumbs if @story.blank? || @context_story_event.blank? || @context_story_event_idea.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: @context_story_event_idea.title,
        path: story_story_event_story_event_idea_path(
          @story,
          @context_story_event,
          @context_story_event_idea,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "要素一覧",
        path: story_story_elements_path(
          @story,
          from: "story_event_idea",
          story_event_id: @context_story_event.id,
          story_event_idea_id: @context_story_event_idea.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_element_page_search_breadcrumbs
    return build_story_elements_index_search_breadcrumbs if @page_story_element.blank?

    if @from == "story_event_idea"
      build_story_event_idea_search_breadcrumbs_with_story_element
    elsif @from == "story_event"
      build_story_event_search_breadcrumbs_with_story_element
    else
      build_story_search_breadcrumbs_with_story_element
    end
  end

  def build_story_search_breadcrumbs_with_story_element
    return build_story_search_breadcrumbs if @story.blank? || @page_story_element.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: "要素一覧",
        path: story_story_elements_path(@story, from: "story")
      },
      {
        name: @page_story_element.name,
        path: story_story_element_path(@story, @page_story_element, from: "story")
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_search_breadcrumbs_with_story_element
    return build_story_elements_index_search_breadcrumbs if @story.blank? || @context_story_event.blank? || @page_story_element.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: "要素一覧",
        path: story_story_elements_path(
          @story,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: @page_story_element.name,
        path: story_story_element_path(
          @story,
          @page_story_element,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_idea_search_breadcrumbs_with_story_element
    return build_story_elements_index_search_breadcrumbs if @story.blank? || @context_story_event.blank? || @context_story_event_idea.blank? || @page_story_element.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: @context_story_event_idea.title,
        path: story_story_event_story_event_idea_path(
          @story,
          @context_story_event,
          @context_story_event_idea,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "要素一覧",
        path: story_story_elements_path(
          @story,
          from: "story_event_idea",
          story_event_id: @context_story_event.id,
          story_event_idea_id: @context_story_event_idea.id
        )
      },
      {
        name: @page_story_element.name,
        path: story_story_element_path(
          @story,
          @page_story_element,
          from: "story_event_idea",
          story_event_id: @context_story_event.id,
          story_event_idea_id: @context_story_event_idea.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_consistency_search_breadcrumbs
    return build_story_event_idea_search_breadcrumbs_with_consistency if @from == "story_event_idea"
    return build_story_event_search_breadcrumbs_with_consistency if @from == "story_event"

    return build_story_search_breadcrumbs if @story.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: "整合性チェック",
        path: consistency_story_path(@story, from: "story")
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_search_breadcrumbs_with_consistency
    return build_story_search_breadcrumbs if @story.blank? || @context_story_event.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: "整合性チェック",
        path: consistency_story_path(
          @story,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def build_story_event_idea_search_breadcrumbs_with_consistency
    return build_story_event_search_breadcrumbs if @story.blank? || @context_story_event.blank? || @context_story_event_idea.blank?

    [
      {
        name: @story.title,
        path: story_path(@story)
      },
      {
        name: @context_story_event.title,
        path: story_story_event_path(@story, @context_story_event, from: "story")
      },
      {
        name: @context_story_event_idea.title,
        path: story_story_event_story_event_idea_path(
          @story,
          @context_story_event,
          @context_story_event_idea,
          from: "story_event",
          story_event_id: @context_story_event.id
        )
      },
      {
        name: "整合性チェック",
        path: consistency_story_path(
          @story,
          from: "story_event_idea",
          story_event_id: @context_story_event.id,
          story_event_idea_id: @context_story_event_idea.id
        )
      },
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def default_search_breadcrumbs
    [
      {
        name: "検索結果",
        path: nil
      }
    ]
  end

  def search_breadcrumb_params
    params_hash =
      case @from
      when "story_event_idea"
        return {} if @context_story_event.blank? || @context_story_event_idea.blank?

        {
          from: "story_event_idea",
          story_event_id: @context_story_event.id,
          story_event_idea_id: @context_story_event_idea.id
        }
      when "story_event"
        return {} if @context_story_event.blank?

        {
          from: "story_event",
          story_event_id: @context_story_event.id
        }
      else
        @story.present? ? { from: "story" } : {}
      end

    params_hash[:page_type] = @page_type if @page_type.present?
    params_hash[:page_id] = @page_id if @page_id.present?
    params_hash
  end

  def resolved_search_context_from_params_or_return_to
    direct_from = params[:from].to_s
    direct_story_event_id = params[:story_event_id].presence&.to_i
    direct_story_event_idea_id = params[:story_event_idea_id].presence&.to_i

    if valid_from_param?(direct_from)
      return {
        from: direct_from,
        story_event_id: direct_story_event_id,
        story_event_idea_id: direct_story_event_idea_id
      }
    end

    return_to_params = extract_query_params_from_path(params[:return_to])

    {
      from: normalized_from_value(return_to_params["from"]),
      story_event_id: return_to_params["story_event_id"].presence&.to_i,
      story_event_idea_id: return_to_params["story_event_idea_id"].presence&.to_i
    }
  end

  def extract_query_params_from_path(path)
    raw_path = safe_path(path)
    return {} if raw_path.blank?

    query = URI.parse(raw_path).query
    return {} if query.blank?

    Rack::Utils.parse_nested_query(query)
  rescue URI::InvalidURIError
    {}
  end

  def normalized_from_value(value)
    from = value.to_s
    valid = %w[story story_event story_event_idea]
    return "story" unless valid.include?(from)

    from
  end

  def valid_from_param?(value)
    %w[story story_event story_event_idea].include?(value.to_s)
  end

  def normalized_page_type(value)
    page_type = value.to_s
    valid = %w[story story_event story_event_idea consistency story_elements_index story_element]
    return nil unless valid.include?(page_type)

    page_type
  end

  def safe_path(value)
    v = value.to_s
    v.start_with?("/") ? v : nil
  end

  def normalize_scope(scope_param)
    s = scope_param.to_s
    return "all" if s.blank?

    valid = %w[all home story event element story_event_idea]
    return "all" unless valid.include?(s)

    s
  end

  def sync_search_story_session(within_story:, story_id:)
    session[:search_story_id] = story_id if story_id.present?
    session[:search_in_story] = within_story && story_id.present?
  end
end
# rubocop:enable Metrics/ClassLength
