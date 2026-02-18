class StoryEventIdeasController < ApplicationController
  before_action :require_login
  before_action :set_story_and_event
  before_action :set_story_event_idea, only: %i[edit update destroy move_up move_down]

  def new
    @story_event_idea = @story_event.story_event_ideas.new
  end

  def create
    @story_event_idea = @story_event.story_event_ideas.new(story_event_idea_params)
    if @story_event_idea.save
      redirect_to story_story_event_path(@story, @story_event), notice: "詳細メモを追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @story_event_idea.update(story_event_idea_params)
      redirect_to story_story_event_path(@story, @story_event), notice: "詳細メモを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story_event_idea.destroy!
    redirect_to story_story_event_path(@story, @story_event), notice: "詳細メモを削除しました"
  end

  # --- 並び替え ---
  def move_up
    ideas = @story_event.story_event_ideas.order(:position, :created_at).to_a
    idx = ideas.index(@story_event_idea)
    return redirect_to story_story_event_path(@story, @story_event) if idx.nil? || idx.zero?

    ideas[idx], ideas[idx - 1] = ideas[idx - 1], ideas[idx]
    resequence_positions!(ideas)

    redirect_to story_story_event_path(@story, @story_event), notice: "並び替えました"
  end

  def move_down
    ideas = @story_event.story_event_ideas.order(:position, :created_at).to_a
    idx = ideas.index(@story_event_idea)
    return redirect_to story_story_event_path(@story, @story_event) if idx.nil? || idx == ideas.length - 1

    ideas[idx], ideas[idx + 1] = ideas[idx + 1], ideas[idx]
    resequence_positions!(ideas)

    redirect_to story_story_event_path(@story, @story_event), notice: "並び替えました"
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
        idea.update_column(:position, i + 1) # 確実に順番を更新
      end
    end
  end
end
