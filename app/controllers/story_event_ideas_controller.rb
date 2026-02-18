class StoryEventIdeasController < ApplicationController
  before_action :require_login
  before_action :set_story_and_event
  before_action :set_story_event_idea, only: %i[edit update destroy move_up move_down]

  def new
    @story_event_idea = @story_event.story_event_ideas.new
  end

  def edit; end

  def create
    @story_event_idea = @story_event.story_event_ideas.new(story_event_idea_params)
    if @story_event_idea.save
      redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story_event_idea.update(story_event_idea_params)
      redirect_to story_story_event_path(@story, @story_event), notice: t("flash.story_event_ideas.updated")
    else
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
    @story_event_idea = @story_event.story_event_ideas.find(params[:id])
  end

  def story_event_idea_params
    params.require(:story_event_idea).permit(:title, :memo, :image, :position)
  end

  def resequence_positions!(ideas)
    ActiveRecord::Base.transaction do
      ideas.each_with_index do |idea, i|
        idea.update!(position: i + 1) # update_column禁止対応（バリデーション通す）
      end
    end
  end
end
