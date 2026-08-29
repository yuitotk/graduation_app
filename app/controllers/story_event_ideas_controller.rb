# rubocop:disable Metrics/ClassLength
# app/controllers/story_event_ideas_controller.rb
class StoryEventIdeasController < ApplicationController
  before_action :require_login
  before_action :set_story_and_event
  before_action :set_story_event_idea, only: %i[show edit update destroy move_up move_down]
  before_action :set_breadcrumbs, only: %i[show new edit]

  def show
    base =
      current_user.ideas
                  .joins(:idea_placement)
                  .where(
                    idea_placements: {
                      placeable_type: "StoryEventIdea",
                      placeable_id: @story_event_idea.id
                    }
                  )
                  .includes(:idea_placement)
                  .distinct

    @created_here_ideas =
      base.where(idea_placements: { created_here: true })
          .order(created_at: :desc)
          .page(params[:created_here_page])

    @moved_ideas =
      base.where(idea_placements: { created_here: false })
          .order("idea_placements.moved_at DESC")
          .page(params[:moved_page])
  end

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
    moved = idx.present? && !idx.zero?

    if moved
      ideas[idx], ideas[idx - 1] = ideas[idx - 1], ideas[idx]
      resequence_positions!(ideas)
    end

    render_reordered_story_event_ideas(moved: moved)
  end

  def move_down
    ideas = @story_event.story_event_ideas.order(:position, :created_at).to_a
    idx = ideas.index(@story_event_idea)
    moved = idx.present? && idx != ideas.length - 1

    if moved
      ideas[idx], ideas[idx + 1] = ideas[idx + 1], ideas[idx]
      resequence_positions!(ideas)
    end

    render_reordered_story_event_ideas(moved: moved)
  end

  private

  def set_story_and_event
    @story = current_user.stories.find(params[:story_id])
    @story_event = @story.story_events.find(params[:story_event_id])
  end

  def set_story_event_idea
    target_id = params[:story_event_idea_id].presence || params[:id]

    @story_event_idea = @story_event.story_event_ideas
                                    .includes(:story_elements)
                                    .find(target_id)
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

  # 並び替え後の一覧を返す。Turbo Streamならその場で一覧部分だけ差し替え、
  # それ以外(JS無効など)は今まで通りイベント詳細へリダイレクトする。
  # 一番上/一番下で、これ以上動かせなかった場合(moved: false)は、
  # 今まで通り「並び替えました」の通知は出さない。
  # 並び替え前に見ていたページ番号(ideas_page)はそのまま保ち、
  # 並び替えるたびに1ページ目に戻ってしまわないようにする。
  def render_reordered_story_event_ideas(moved:)
    @story_event_ideas =
      @story_event.story_event_ideas
                  .order(:position, :created_at)
                  .page(params[:ideas_page])

    respond_to do |format|
      format.turbo_stream { render "reorder" }
      format.html do
        if moved
          redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.reordered")
        else
          redirect_to story_story_event_path(@story, @story_event)
        end
      end
    end
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
