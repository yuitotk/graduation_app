# app/controllers/story_events_controller.rb
class StoryEventsController < ApplicationController
  before_action :require_login
  before_action :set_story
  before_action :set_story_event, only: %i[show edit update destroy move_up move_down]

  def show; end

  def new
    @story_event = @story.story_events.new
  end

  def edit; end

  def create
    @story_event = @story.story_events.new(story_event_params)
    @story_event.position = next_position_for(@story)

    if @story_event.save
      redirect_to story_path(@story), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story_event.update(story_event_params)
      redirect_to story_path(@story), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story_event.destroy!
    redirect_to story_path(@story), notice: t(".success")
  end

  def move_up
    return redirect_to(story_path(@story)) if @story_event.position.nil?

    upper = @story.story_events
                  .where.not(position: nil)
                  .where(position: ...@story_event.position)
                  .order(position: :desc)
                  .first

    swap_positions(@story_event, upper)
    redirect_to story_path(@story)
  end

  def move_down
    return redirect_to(story_path(@story)) if @story_event.position.nil?

    lower = @story.story_events
                  .where.not(position: nil)
                  .where(position: (@story_event.position + 1)..)
                  .order(position: :asc)
                  .first

    swap_positions(@story_event, lower)
    redirect_to story_path(@story)
  end

  private

  def set_story
    @story = current_user.stories.find(params[:story_id])
  end

  def set_story_event
    @story_event = @story.story_events
                         .includes(:story_elements, story_event_ideas: :story_elements)
                         .find(params[:id])
  end

  def story_event_params
    params.require(:story_event).permit(
      :title, :body,
      story_element_ids: []
    )
  end

  def swap_positions(first_record, second_record)
    return if second_record.nil?

    first_pos = first_record.position
    first_record.update!(position: second_record.position)
    second_record.update!(position: first_pos)
  end

  def next_position_for(story)
    (story.story_events.maximum(:position) || 0) + 10
  end
end
