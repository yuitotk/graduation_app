class StoryElementsController < ApplicationController
  before_action :require_login
  before_action :set_story
  before_action :set_story_element, only: %i[show edit update destroy]

  def index
    @story_elements = @story.story_elements.order(:id)
  end

  def show
    @created_here_ideas =
      @story_element.placed_ideas
                    .joins(:idea_placement)
                    .where(idea_placements: { created_here: true })
                    .order(created_at: :desc)

    @moved_ideas =
      @story_element.placed_ideas
                    .joins(:idea_placement)
                    .where(idea_placements: { created_here: false })
                    .order(created_at: :desc)
  end

  def new
    @story_element = @story.story_elements.new
  end

  def edit; end

  def create
    @story_element = @story.story_elements.new(story_element_params)
    if @story_element.save
      redirect_to story_story_elements_path(@story), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story_element.update(story_element_params)
      redirect_to story_story_elements_path(@story), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story_element.destroy!
    redirect_to story_story_elements_path(@story), notice: t(".success")
  end

  private

  def set_story
    @story = current_user.stories.find(params[:story_id])
  end

  def set_story_element
    @story_element = @story.story_elements.find(params[:id])
  end

  def story_element_params
    params.require(:story_element).permit(:kind, :name, :memo, :marker)
  end
end
