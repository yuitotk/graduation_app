# rubocop:disable Metrics/ClassLength
class IdeasController < ApplicationController
  before_action :require_login
  before_action :set_idea, only: %i[show edit update destroy]

  def index
    # ✅ ホーム＝「どこにも移動していないアイデア」だけ表示
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
  end

  def new
    @idea = current_user.ideas.new
    @idea.build_idea_image if @idea.idea_image.nil?

    # ストーリー/イベント/要素から来た new は placement を持たせる（created_here: true）
    if params[:placeable_type].present? && params[:placeable_id].present?
      @idea.build_idea_placement(
        placeable_type: params[:placeable_type],
        placeable_id: params[:placeable_id],
        created_here: true
      )
    end

    set_marker_options
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def create
    @idea = current_user.ideas.new(idea_params)
    @idea.build_idea_image if @idea.idea_image.nil?

    pt  = params.dig(:idea, :idea_placement_attributes, :placeable_type).presence
    pid = params.dig(:idea, :idea_placement_attributes, :placeable_id).presence

    # ✅ ストーリー/イベント/要素からの作成だけ placement を確定させる
    if pt.present? && pid.present?
      placement = @idea.idea_placement || @idea.build_idea_placement
      placement.placeable_type = pt
      placement.placeable_id   = pid
      placement.created_here   = true

      element_ids = params.dig(:idea, :idea_placement_attributes, :story_element_ids)
      placement.story_element_ids = Array(element_ids).compact_blank
    end

    if @idea.save
      redirect_to(safe_path(params[:return_to]) || @idea, notice: "アイデアを作成しました")
    else
      @idea.build_idea_image if @idea.idea_image.nil?
      set_marker_options
      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

  def edit
    @idea.build_idea_image if @idea.idea_image.nil?

    if @idea.idea_placement.present?
      set_marker_options
    else
      @marker_options = []
    end
  end

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
        set_marker_options
      else
        @marker_options = []
      end

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @idea.destroy!
    redirect_to ideas_path, notice: "アイデアを削除しました"
  end

  private

  def set_idea
    @idea = current_user.ideas.find(params[:id])
  end

  # ✅ story_element_ids: [] を許可
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

  def set_marker_options
    story = resolve_story_for_marker
    @marker_options = marker_options_for(story)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def resolve_story_for_marker
    return Story.find(params[:story_id]) if params[:story_id].present?
    return StoryEvent.find(params[:story_event_id]).story if params[:story_event_id].present?
    return StoryElement.find(params[:story_element_id]).story if params[:story_element_id].present?

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

  def marker_options_for(story)
    return [] if story.nil?

    elements = story.story_elements
    elements = elements.order(:position) if elements.respond_to?(:klass) && elements.klass.column_names.include?("position")

    elements.map do |element|
      marker = element.marker.presence
      name   = element.name.presence
      kind   = element.kind.presence
      label  = [marker, name, kind].compact.join(" ")
      value  = element.id.to_s
      [label, value]
    end
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
    end
  end

  def story_for_placeable(placeable)
    case placeable
    when Story
      placeable
    when StoryEvent, StoryElement
      placeable.story
    end
  end
end
# rubocop:enable Metrics/ClassLength
