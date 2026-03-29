# app/controllers/ideas_controller.rb
# rubocop:disable Metrics/ClassLength
class IdeasController < ApplicationController
  before_action :require_login
  before_action :sync_search_story_context_from_placeable, only: %i[new create]
  before_action :set_idea, only: %i[show edit update destroy]
  before_action :sync_search_story_context_from_idea, only: %i[show edit update]
  before_action :set_breadcrumbs_for_new, only: %i[new]
  before_action :set_breadcrumbs_for_existing_idea, only: %i[show edit]

  def index
    @ideas = current_user.ideas
                         .where.missing(:idea_placement)
                         .order(created_at: :desc)
  end

  def show
    @tab = params[:tab].presence

    @stories = current_user.stories.order(created_at: :desc)
    story_ids = @stories.pluck(:id)

    @story_events = StoryEvent.where(story_id: story_ids).order(created_at: :desc)
    @story_elements = StoryElement.includes(:story).where(story_id: story_ids).to_a
    @story_event_ideas = StoryEventIdea.includes(story_event: :story)
                                       .joins(story_event: :story)
                                       .where(stories: { user_id: current_user.id })
                                       .order(created_at: :desc)
  end

  def new
    @idea = current_user.ideas.new
    @idea.build_idea_image if @idea.idea_image.nil?

    if params[:placeable_type].present? && params[:placeable_id].present?
      @idea.build_idea_placement(
        placeable_type: params[:placeable_type],
        placeable_id: params[:placeable_id],
        created_here: true
      )
    end

    set_available_story_elements
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    @idea = current_user.ideas.new(idea_params)
    @idea.build_idea_image if @idea.idea_image.nil?

    pt  = params.dig(:idea, :idea_placement_attributes, :placeable_type).presence
    pid = params.dig(:idea, :idea_placement_attributes, :placeable_id).presence

    if pt.present? && pid.present?
      placement = @idea.idea_placement || @idea.build_idea_placement
      placement.placeable_type = pt
      placement.placeable_id   = pid
      placement.created_here   = true
      placement.moved_at       = Time.current

      element_ids = params.dig(:idea, :idea_placement_attributes, :story_element_ids)
      placement.story_element_ids = Array(element_ids).compact_blank
    end

    if @idea.save
      redirect_to(safe_path(params[:return_to]) || ideas_path, notice: "アイデアを作成しました")
    else
      @idea.build_idea_image if @idea.idea_image.nil?
      set_available_story_elements
      placeable = find_placeable_for_current_user(pt || params[:placeable_type], pid || params[:placeable_id])
      assign_breadcrumbs_from_placeable(placeable)
      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def edit
    @idea.build_idea_image if @idea.idea_image.nil?

    if @idea.idea_placement.present?
      set_available_story_elements
    else
      @available_story_elements = []
    end
  end

  # rubocop:disable Metrics/AbcSize
  def update
    filtered_params = idea_params
    filtered_params = filtered_params.except(:idea_placement_attributes) if @idea.idea_placement.blank?

    if @idea.update(filtered_params)
      if @idea.idea_placement.present?
        element_ids = params.dig(:idea, :idea_placement_attributes, :story_element_ids)
        @idea.idea_placement.story_element_ids = Array(element_ids).compact_blank
      end

      redirect_to @idea, notice: "アイデアを更新しました"
    else
      @idea.build_idea_image if @idea.idea_image.nil?

      if @idea.idea_placement.present?
        set_available_story_elements
      else
        @available_story_elements = []
      end

      set_breadcrumbs_for_existing_idea
      render :edit, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def destroy
    redirect_path =
      case @idea.idea_placement&.placeable
      when Story
        story_path(@idea.idea_placement.placeable)
      when StoryEvent
        story_story_event_path(@idea.idea_placement.placeable.story, @idea.idea_placement.placeable)
      when StoryElement
        story_story_element_path(@idea.idea_placement.placeable.story, @idea.idea_placement.placeable)
      when StoryEventIdea
        story_story_event_story_event_idea_path(
          @idea.idea_placement.placeable.story_event.story,
          @idea.idea_placement.placeable.story_event,
          @idea.idea_placement.placeable
        )
      else
        ideas_path
      end

    @idea.destroy!
    redirect_to redirect_path, notice: "アイデアを削除しました"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def set_breadcrumbs_for_new
    placeable = find_placeable_for_current_user(params[:placeable_type], params[:placeable_id])
    assign_breadcrumbs_from_placeable(placeable)
  end

  def set_breadcrumbs_for_existing_idea
    placeable = @idea.idea_placement&.placeable
    assign_breadcrumbs_from_placeable(placeable)
  end

  def assign_breadcrumbs_from_placeable(placeable)
    @breadcrumbs = breadcrumb_items_for_placeable(placeable)
  end

  def breadcrumb_items_for_placeable(placeable)
    case placeable
    when Story
      story_breadcrumbs(placeable)
    when StoryEvent
      story_event_breadcrumbs(placeable)
    when StoryEventIdea
      story_event_idea_breadcrumbs(placeable)
    when StoryElement
      story_element_breadcrumbs(placeable)
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

  def story_element_breadcrumbs(story_element)
    story = story_element.story

    [
      { name: story.title, path: story_path(story) },
      { name: "要素一覧", path: story_story_elements_path(story) },
      { name: story_element.name, path: nil }
    ]
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def sync_search_story_context_from_placeable
    pt = params[:placeable_type].to_s
    pid = params[:placeable_id].presence&.to_i
    return if pt.blank? || pid.blank?

    story =
      case pt
      when "Story"
        current_user.stories.find_by(id: pid)
      when "StoryEvent"
        StoryEvent.joins(:story)
                  .where(stories: { user_id: current_user.id })
                  .find_by(id: pid)&.story
      when "StoryElement"
        StoryElement.joins(:story)
                    .where(stories: { user_id: current_user.id })
                    .find_by(id: pid)&.story
      when "StoryEventIdea"
        StoryEventIdea.joins(story_event: :story)
                      .where(stories: { user_id: current_user.id })
                      .find_by(id: pid)&.story_event&.story
      end

    return if story.blank?

    session[:search_story_id] = story.id
    session[:search_in_story] = true if session[:search_in_story].nil?
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def set_idea
    @idea = current_user.ideas.find(params[:id])
  end

  # rubocop:disable Metrics/AbcSize
  def sync_search_story_context_from_idea
    placement = @idea.idea_placement

    if placement.blank?
      session[:search_story_id] = nil
      session[:search_in_story] = false
      return
    end

    story =
      case placement.placeable
      when Story
        placement.placeable
      when StoryEvent, StoryElement
        placement.placeable.story
      when StoryEventIdea
        placement.placeable.story_event.story
      end

    return if story.blank?

    session[:search_story_id] = story.id
    session[:search_in_story] = true if session[:search_in_story].nil?
  end
  # rubocop:enable Metrics/AbcSize

  def idea_params
    params.require(:idea).permit(
      :title, :memo,
      idea_image_attributes: %i[id image image_cache remove_image],
      idea_placement_attributes: [
        :id, :placeable_type, :placeable_id,
        { story_element_ids: [] }
      ]
    )
  end

  def set_available_story_elements
    story = resolve_story_for_marker
    @available_story_elements = available_story_elements_for(story)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def resolve_story_for_marker
    return Story.find(params[:story_id]) if params[:story_id].present?
    return StoryEvent.find(params[:story_event_id]).story if params[:story_event_id].present?
    return StoryElement.find(params[:story_element_id]).story if params[:story_element_id].present?
    return StoryEventIdea.find(params[:story_event_idea_id]).story_event.story if params[:story_event_idea_id].present?

    if params[:placeable_type].present? && params[:placeable_id].present?
      placeable = find_placeable_for_current_user(params[:placeable_type], params[:placeable_id])
      return story_for_placeable(placeable) if placeable.present?
    end

    placement = @idea&.idea_placement
    return nil if placement.nil?

    placeable = placement.placeable
    return nil if placeable.nil?

    story_for_placeable(placeable)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def available_story_elements_for(story)
    return [] if story.nil?

    elements = story.story_elements
    elements = elements.order(:position) if elements.respond_to?(:klass) && elements.klass.column_names.include?("position")
    elements
  end

  def safe_path(value)
    v = value.to_s
    v.start_with?("/") ? v : nil
  end

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

  def story_for_placeable(placeable)
    case placeable
    when Story
      placeable
    when StoryEvent, StoryElement
      placeable.story
    when StoryEventIdea
      placeable.story_event.story
    end
  end
end
# rubocop:enable Metrics/ClassLength
