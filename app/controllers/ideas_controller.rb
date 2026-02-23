class IdeasController < ApplicationController
  before_action :require_login

  def index
    @ideas = current_user.ideas
                         .where.missing(:idea_placement) # ✅ 移動先があるか結合
                         .order(created_at: :desc)
  end

  def new
    @idea = current_user.ideas.build
    @idea.build_idea_image
  end

  def create
    @idea = current_user.ideas.build(idea_params)

    if @idea.save
      redirect_to @idea, notice: "アイデアを作成しました"
    else
      flash.now[:alert] = "保存できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @idea = current_user.ideas.find(params[:id])
    @tab = params[:tab] # "elements" / "stories" / "events"

    case @tab
    when "elements"
      # キャラ（要素）一覧：自分のストーリー配下だけ
      @story_elements = StoryElement
                        .joins(:story)
                        .where(stories: { user_id: current_user.id })
                        .includes(:story)
                        .order("stories.created_at DESC, story_elements.created_at DESC")

    when "stories"
      # ストーリー一覧
      @stories = current_user.stories.order(created_at: :desc)

    when "events"
      # イベント一覧（=イベント詳細に行ける）
      @story_events = StoryEvent
                      .joins(:story)
                      .where(stories: { user_id: current_user.id })
                      .includes(:story)
                      .order("stories.created_at DESC, story_events.position ASC, story_events.created_at ASC")
    end
  end

  def edit
    @idea = current_user.ideas.find(params[:id])
    @idea.build_idea_image unless @idea.idea_image
  end

  def update
    @idea = current_user.ideas.find(params[:id])

    if @idea.update(idea_params)
      redirect_to @idea, notice: "アイデアを更新しました"
    else
      flash.now[:alert] = "更新できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @idea = current_user.ideas.find(params[:id])
    @idea.destroy
    redirect_to ideas_path, notice: "アイデアを削除しました"
  end

  private

  def idea_params
    params.require(:idea).permit(:title, :memo, idea_image_attributes: [:id, :image])
  end
end
