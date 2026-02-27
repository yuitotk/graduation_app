# app/controllers/idea_placements_controller.rb
class IdeaPlacementsController < ApplicationController
  before_action :require_login

  def create
    idea = current_user.ideas.find(params[:idea_id])
    placeable = find_placeable!(params[:placeable_type], params[:placeable_id])

    # ✅ 即移動：既存があれば更新（1アイデア=1移動先）
    placement = idea.idea_placement || idea.build_idea_placement
    placement.placeable = placeable
    placement.created_here = false
    placement.save!

    redirect_to redirect_target(placeable), notice: t("flash.idea_placements.moved")
  end

  private

  def find_placeable!(type, id)
    case type
    when "Story"
      current_user.stories.find(id)
    when "StoryEvent"
      StoryEvent.joins(:story).where(stories: { user_id: current_user.id }).find(id)
    when "StoryElement"
      StoryElement.joins(:story).where(stories: { user_id: current_user.id }).find(id)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def redirect_target(placeable)
    case placeable
    when Story
      story_path(placeable)
    when StoryEvent
      story_story_event_path(placeable.story, placeable) # イベント詳細（メモ一覧）
    when StoryElement
      story_story_element_path(placeable.story, placeable) # キャラ詳細
    else
      ideas_path
    end
  end
end
