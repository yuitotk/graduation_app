# rubocop:disable Metrics/ClassLength
# app/controllers/story_event_ideas_controller.rb
class StoryEventIdeasController < ApplicationController
  before_action :require_login
  before_action :set_story_and_event
  before_action :set_story_event_idea, only: %i[show edit update destroy move_up move_down]
  before_action :set_breadcrumbs, only: %i[show new edit]

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def show
    ideas = current_user.ideas
                        .joins(:idea_placement)
                        .where(idea_placements: { placeable_type: "StoryEventIdea", placeable_id: @story_event_idea.id })
                        .includes(:idea_placement)
                        .distinct
                        .order(created_at: :desc)

    @created_here_ideas = ideas.select do |idea|
      placement = idea.idea_placement
      placement.present? &&
        placement.placeable_type == "StoryEventIdea" &&
        placement.placeable_id == @story_event_idea.id &&
        placement.created_here?
    end

    @moved_ideas = ideas.select do |idea|
      placement = idea.idea_placement
      placement.present? &&
        placement.placeable_type == "StoryEventIdea" &&
        placement.placeable_id == @story_event_idea.id &&
        !placement.created_here?
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def new
    @story_event_idea = @story_event.story_event_ideas.new

    return if params[:idea_id].blank?

    idea = current_user.ideas.find_by(id: params[:idea_id])
    @story_event_idea.idea_id = idea.id if idea
  end

  def edit; end

  def create
    @story_event_idea = @story_event.story_event_ideas.new(story_event_idea_params)
    @story_event_idea.position = next_position_for(@story_event)

    if @story_event_idea.save
      redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.created")
    else
      @breadcrumbs = [
        { name: @story.title, path: story_path(@story) },
        { name: @story_event.title, path: nil }
      ]
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story_event_idea.update(story_event_idea_params)
      redirect_to story_story_event_story_event_idea_path(@story, @story_event, @story_event_idea),
                  notice: t("flash.story_event_ideas.updated")
    else
      @breadcrumbs = [
        { name: @story.title, path: story_path(@story) },
        { name: @story_event.title, path: story_story_event_path(@story, @story_event) },
        { name: @story_event_idea.title, path: nil }
      ]
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story_event_idea.destroy!
    redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.destroyed")
  end

  def move_up
    ideas = @story_event.story_event_ideas.order(:position, :created_at).to_a
    idx = ideas.index(@story_event_idea)
    return redirect_to story_story_event_path(@story, @story_event) if idx.nil? || idx.zero?

    ideas[idx], ideas[idx - 1] = ideas[idx - 1], ideas[idx]
    resequence_positions!(ideas)

    redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.reordered")
  end

  def move_down
    ideas = @story_event.story_event_ideas.order(:position, :created_at).to_a
    idx = ideas.index(@story_event_idea)
    return redirect_to story_story_event_path(@story, @story_event) if idx.nil? || idx == ideas.length - 1

    ideas[idx], ideas[idx + 1] = ideas[idx + 1], ideas[idx]
    resequence_positions!(ideas)

    redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.reordered")
  end

  private

  def set_story_and_event
    @story = current_user.stories.find(params[:story_id])
    @story_event = @story.story_events.find(params[:story_event_id])
  end

  def set_story_event_idea
    @story_event_idea = @story_event.story_event_ideas
                                    .includes(:story_elements)
                                    .find(params[:id])
  end

  def set_breadcrumbs
    @breadcrumbs =
      case action_name
      when "show", "edit"
        [
          { name: @story.title, path: story_path(@story) },
          { name: @story_event.title, path: story_story_event_path(@story, @story_event) },
          { name: @story_event_idea.title, path: nil }
        ]
      when "new"
        [
          { name: @story.title, path: story_path(@story) },
          { name: @story_event.title, path: nil }
        ]
      else
        []
      end
  end

  def story_event_idea_params
    params.require(:story_event_idea).permit(
      :title, :memo, :image, :remove_image, :position,
      :idea_id,
      story_element_ids: []
    )
  end

  def resequence_positions!(ideas)
    ActiveRecord::Base.transaction do
      ideas.each_with_index do |idea, i|
        idea.update!(position: i + 1)
      end
    end
  end

  def next_position_for(story_event)
    (story_event.story_event_ideas.maximum(:position) || 0) + 10
  end
end
# rubocop:enable Metrics/ClassLength
