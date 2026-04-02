# rubocop:disable Metrics/ClassLength
class StoryElementsController < ApplicationController
  helper_method :breadcrumb_params

  before_action :require_login
  before_action :set_story
  before_action :set_story_element, only: %i[show edit update destroy]
  before_action :sync_search_story_session, only: %i[index show new edit]
  before_action :set_breadcrumbs, only: %i[index show new edit]

  def index
    @story_elements = @story.story_elements.order(:id)
  end

  def show
    @current_story = @story

    @created_here_ideas =
      @story_element.placed_ideas
                    .joins(:idea_placement)
                    .where(idea_placements: { created_here: true })
                    .order(created_at: :desc)

    @moved_ideas =
      @story_element.placed_ideas
                    .joins(:idea_placement)
                    .where(idea_placements: { created_here: false })
                    .order("idea_placements.moved_at DESC")
  end

  def new
    @story_element = @story.story_elements.new
    @story_element.build_story_element_image if @story_element.story_element_image.nil?
  end

  def edit
    @story_element.build_story_element_image if @story_element.story_element_image.nil?
  end

  def create
    @story_element = @story.story_elements.new(story_element_params)
    @story_element.build_story_element_image if @story_element.story_element_image.nil?

    if @story_element.save
      redirect_to story_story_elements_path(@story, breadcrumb_params), notice: t(".success")
    else
      @breadcrumbs =
        base_breadcrumbs + [
          { name: "要素一覧", path: nil }
        ]
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story_element.update(story_element_params)
      redirect_to story_story_element_path(@story, @story_element, breadcrumb_params), notice: t(".success")
    else
      @story_element.build_story_element_image if @story_element.story_element_image.nil?
      @breadcrumbs =
        base_breadcrumbs + [
          { name: "要素一覧", path: story_story_elements_path(@story, breadcrumb_params) },
          { name: @story_element.name, path: nil }
        ]
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story_element.destroy!
    redirect_to story_story_elements_path(@story, breadcrumb_params), notice: t(".success")
  end

  private

  def set_story
    @story = current_user.stories.find(params[:story_id])
  end

  def set_story_element
    @story_element = @story.story_elements.find(params[:id])
  end

  def set_breadcrumbs
    @breadcrumbs =
      case action_name
      when "index", "new"
        base_breadcrumbs + [
          { name: "要素一覧", path: nil }
        ]
      when "show", "edit"
        base_breadcrumbs + [
          { name: "要素一覧", path: story_story_elements_path(@story, breadcrumb_params) },
          { name: @story_element.name, path: nil }
        ]
      else
        []
      end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def base_breadcrumbs
    case params[:from]
    when "story_event_idea"
      if params[:story_event_id].present? && params[:story_event_idea_id].present?
        story_event = @story.story_events.find(params[:story_event_id])
        story_event_idea = story_event.story_event_ideas.find(params[:story_event_idea_id])

        [
          { name: @story.title, path: story_path(@story) },
          { name: story_event.title, path: story_story_event_path(@story, story_event) },
          {
            name: story_event_idea.title,
            path: story_story_event_story_event_idea_path(@story, story_event, story_event_idea)
          }
        ]
      else
        [
          { name: @story.title, path: story_path(@story) }
        ]
      end
    when "story_event"
      if params[:story_event_id].present?
        story_event = @story.story_events.find(params[:story_event_id])

        [
          { name: @story.title, path: story_path(@story) },
          { name: story_event.title, path: story_story_event_path(@story, story_event) }
        ]
      else
        [
          { name: @story.title, path: story_path(@story) }
        ]
      end
    else
      [
        { name: @story.title, path: story_path(@story) }
      ]
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def breadcrumb_params
    params.permit(:from, :story_event_id, :story_event_idea_id).to_h.symbolize_keys
  end

  # ✅ ストーリー配下に入ったら「この作品」を session に固定
  def sync_search_story_session
    session[:search_story_id] = @story.id
    session[:search_in_story] = true
  end

  def story_element_params
    params.require(:story_element).permit(
      :kind, :name, :memo, :marker,
      story_element_image_attributes: %i[id image image_cache remove_image]
    )
  end
end
# rubocop:enable Metrics/ClassLength
