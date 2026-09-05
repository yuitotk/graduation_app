# app/controllers/idea_placements_controller.rb
class IdeaPlacementsController < ApplicationController
  before_action :require_login

  def create
    idea = current_user.ideas.find(params[:idea_id])
    placeable = find_placeable!(params[:placeable_type], params[:placeable_id])

    return block_move_out_of_sample_story(idea) if move_out_of_sample_story?(idea, placeable)

    move_idea!(idea, placeable)
    redirect_to redirect_target(placeable), notice: t("flash.idea_placements.moved")
  end

  private

  def block_move_out_of_sample_story(idea)
    redirect_to idea_path(idea), alert: t("flash.idea_placements.cannot_move_sample_idea_out")
  end

  def move_idea!(idea, placeable)
    placement = idea.idea_placement || idea.build_idea_placement
    placement.placeable = placeable
    placement.created_here = false
    placement.moved_at = Time.current
    placement.save!
  end

  # ✅ 見本ストーリーの中にすでに配置されている見本アイデアを、
  #    その見本ストーリーの外へ移動しようとしていないか確認する。
  #    ホームに残っている未配置の見本アイデア（ストーリー化候補）には掛からない。
  def move_out_of_sample_story?(idea, destination_placeable)
    return false unless idea.confined_to_sample_story?

    story_of(destination_placeable) != idea.current_story
  end

  # ✅ 配置先(placeable)が、種類によらずどのストーリーに属しているか
  def story_of(placeable)
    placeable.is_a?(Story) ? placeable : placeable.story
  end

  def find_placeable!(type, id)
    case type
    when "Story"
      current_user.stories.find(id)
    when "StoryEvent"
      StoryEvent.joins(:story).where(stories: { user_id: current_user.id }).find(id)
    when "StoryElement"
      StoryElement.joins(:story).where(stories: { user_id: current_user.id }).find(id)
    when "StoryEventIdea"
      StoryEventIdea.joins(story_event: :story).where(stories: { user_id: current_user.id }).find(id)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def redirect_target(placeable)
    case placeable
    when Story
      story_path(placeable, redirect_breadcrumb_params)
    when StoryEvent
      story_story_event_path(placeable.story, placeable, redirect_breadcrumb_params)
    when StoryElement
      story_element_redirect_path(placeable)
    when StoryEventIdea
      story_event_idea_redirect_path(placeable)
    else
      ideas_path
    end
  end

  def story_element_redirect_path(placeable)
    story_story_element_path(
      placeable.story,
      placeable,
      redirect_breadcrumb_params.merge(
        page_type: "story_element",
        page_id: placeable.id
      )
    )
  end

  def story_event_idea_redirect_path(placeable)
    story_story_event_story_event_idea_path(
      placeable.story_event.story,
      placeable.story_event,
      placeable
    )
  end

  def redirect_breadcrumb_params
    {
      from: params[:from],
      story_event_id: params[:story_event_id],
      story_event_idea_id: params[:story_event_idea_id]
    }.compact
  end
end
