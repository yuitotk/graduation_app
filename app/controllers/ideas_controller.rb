class IdeasController < ApplicationController
  before_action :require_login

  def index
    @ideas = current_user.ideas.order(created_at: :desc)
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
