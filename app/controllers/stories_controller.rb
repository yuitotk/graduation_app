class StoriesController < ApplicationController
  before_action :require_login
  before_action :set_story, only: %i[show edit update destroy consistency]

  def index
    @stories = current_user.stories.order(:position, created_at: :desc)
  end

  def show
    @story_events = @story.story_events.order(:position)

    base =
      @story.placed_ideas
            .includes(idea_placement: :story_elements) # ✅ 複数マーカー表示用
            .joins(:idea_placement)
            .order(created_at: :desc)

    # このストーリー内で「ここで新規作成」されたアイデア（created_here: true）
    @created_here_ideas =
      base.where(idea_placements: { created_here: true })

    # 「ここに移動したアイデア」（created_here: false）
    @moved_ideas =
      base.where(idea_placements: { created_here: false })
  end

  # ✅ 整合性チェック（要素で絞り込み）
  def consistency
    @elements = @story.story_elements.order(:kind, :name, :id)

    @selected_element =
      @elements.find_by(id: params[:story_element_id])

    @events =
      if @selected_element
        @story.story_events
              .joins(:story_elements)
              .where(story_elements: { id: @selected_element.id })
              .includes(:story_elements, story_event_ideas: :story_elements)
              .distinct
              .order(:position)
      else
        []
      end
  end

  def new
    @story = current_user.stories.new
  end

  def edit; end

  def create
    @story = current_user.stories.new(story_params)
    @story.position = next_position_for(current_user)

    if @story.save
      redirect_to story_path(@story), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story.update(story_params)
      redirect_to story_path(@story), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story.destroy!
    redirect_to stories_path, notice: t(".success")
  end

  # ↑へ移動
  def move_up
    story = current_user.stories.find(params[:id])
    return redirect_to(stories_path) if story.position.nil?

    upper = current_user.stories
                        .where.not(position: nil)
                        .where(position: ...story.position)
                        .order(position: :desc)
                        .first

    swap_positions(story, upper)
    redirect_to stories_path
  end

  # ↓へ移動
  def move_down
    story = current_user.stories.find(params[:id])
    return redirect_to(stories_path) if story.position.nil?

    lower = current_user.stories
                        .where.not(position: nil)
                        .where(position: (story.position + 1)..)
                        .order(position: :asc)
                        .first

    swap_positions(story, lower)
    redirect_to stories_path
  end

  private

  def set_story
    @story = current_user.stories.find(params[:id])
  end

  def story_params
    params.require(:story).permit(:title, :description)
  end

  def swap_positions(first_record, second_record)
    return if second_record.nil?

    first_pos = first_record.position
    first_record.update!(position: second_record.position)
    second_record.update!(position: first_pos)
  end

  def next_position_for(user)
    (user.stories.maximum(:position) || 0) + 10
  end
end
