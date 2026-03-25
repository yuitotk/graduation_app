# app/controllers/search_controller.rb
# rubocop:disable Metrics/ClassLength
class SearchController < ApplicationController
  before_action :require_login

  def index
    prepare_search_context_for_index
    store_search_return_to
    sync_search_story_session(within_story: @within_story, story_id: @story_id)
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
    assign_story_element_for_index
  end

  def assign_search_params_for_index
    @query        = params[:q].to_s.strip
    @scope        = normalize_scope(params[:scope])
    @within_story = params[:within_story].to_s == "1"
    @story_id     = params[:story_id].presence&.to_i
  end

  def assign_story_for_index
    @story = current_user.stories.find_by(id: @story_id) if @within_story && @story_id
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

  def prepare_search_context_for_suggestions
    scope        = normalize_scope(params[:scope])
    within_story = params[:within_story].to_s == "1"
    story_id     = params[:story_id].presence&.to_i

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
