# rubocop:disable Metrics/ClassLength
class StoriesController < ApplicationController
  before_action :require_login
  before_action :set_story, only: %i[show edit update destroy consistency]
  before_action :sync_search_story_session, only: %i[show consistency]
  before_action :set_breadcrumbs, only: %i[show edit consistency]

  def index
    @stories = current_user.stories.order(:position, created_at: :desc)
  end

  def show
    @current_story = @story

    @story_events = @story.story_events.order(:position).page(params[:events_page])

    base =
      @story.placed_ideas
            .includes(idea_placement: :story_elements)
            .joins(:idea_placement)

    @created_here_ideas =
      base.where(idea_placements: { created_here: true })
          .order(created_at: :desc)
          .page(params[:created_here_page])

    @moved_ideas =
      base.where(idea_placements: { created_here: false })
          .order("idea_placements.moved_at DESC")
          .page(params[:moved_page])
  end

  # ✅ 整合性チェック（要素で絞り込み。複数選んだ場合は全員そろって登場するイベントのみ表示）
  def consistency
    @elements = StoryElement.sorted_by_kind_and_name(@story.story_elements)

    selected_ids = Array(params[:consistency_story_element_ids]).map(&:to_i).reject(&:zero?).uniq

    # 画像を表示する「選択中の要素」カード用に、選ばれた要素だけ改めて
    # story_element_image込みで取得する（@elements全体をincludesすると、
    # 選ばれなかった要素の分が無駄なeager loadになるため分けている）
    @selected_elements =
      if selected_ids.present?
        StoryElement.sorted_by_kind_and_name(
          @story.story_elements.where(id: selected_ids).includes(:story_element_image)
        )
      else
        []
      end

    @events =
      if @selected_elements.present?
        matching_event_ids = events_matching_all_elements(@selected_elements.map(&:id)).pluck(:id)

        # viewでは event.story_event_ideas.joins(...).where(...) のように
        # 都度絞り込みクエリを投げ直しており、ここでincludesしても使われず
        # 無駄な事前読み込みになるため付けない
        @story.story_events
              .where(id: matching_event_ids)
              .order(:position)
      else
        []
      end
  end

  def new
    @story = current_user.stories.new
    @story.build_story_image if @story.story_image.nil?
  end

  def edit
    @story.build_story_image if @story.story_image.nil?
  end

  def create
    @story = current_user.stories.new(story_params)
    @story.build_story_image if @story.story_image.nil?
    @story.position = next_position_for(current_user)

    if @story.save
      redirect_to stories_path, notice: t(".success")
    else
      @story.build_story_image if @story.story_image.nil?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @story.update(story_params)
      redirect_to story_path(@story), notice: t(".success")
    else
      @story.build_story_image if @story.story_image.nil?
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
    render_reordered_stories
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
    render_reordered_stories
  end

  private

  def set_story
    @story = current_user.stories.find(params[:id])
  end

  def set_breadcrumbs
    @breadcrumbs =
      case action_name
      when "show", "edit"
        [
          { name: @story.title, path: nil }
        ]
      when "consistency"
        consistency_breadcrumbs
      else
        []
      end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def consistency_breadcrumbs
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
          },
          { name: "整合性チェック", path: nil }
        ]
      else
        [
          { name: @story.title, path: story_path(@story) },
          { name: "整合性チェック", path: nil }
        ]
      end
    when "story_event"
      if params[:story_event_id].present?
        story_event = @story.story_events.find(params[:story_event_id])

        [
          { name: @story.title, path: story_path(@story) },
          { name: story_event.title, path: story_story_event_path(@story, story_event) },
          { name: "整合性チェック", path: nil }
        ]
      else
        [
          { name: @story.title, path: story_path(@story) },
          { name: "整合性チェック", path: nil }
        ]
      end
    else
      [
        { name: @story.title, path: story_path(@story) },
        { name: "整合性チェック", path: nil }
      ]
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # 渡された要素IDが「全員そろって」紐づいているイベントだけに絞り込む。
  # GROUP BY + HAVING で絞り込んだ後、id一覧だけ取り出して別クエリで読み直す
  # （GROUP BYした結果に対してそのままincludesすると、MySQLのONLY_FULL_GROUP_BYに
  #   違反するため2段階に分けている）
  def events_matching_all_elements(element_ids)
    @story.story_events
          .joins(:story_elements)
          .where(story_elements: { id: element_ids })
          .group(:id)
          .having("COUNT(DISTINCT story_elements.id) = ?", element_ids.size)
  end

  # ✅ ストーリー配下に入ったら「この作品」を session に固定
  # これでヘッダーの「この作品内（◯◯）」が安定する
  def sync_search_story_session
    session[:search_story_id] = @story.id
    session[:search_in_story] = true
  end

  def story_params
    params.require(:story).permit(
      :title, :description,
      story_image_attributes: %i[id image image_cache remove_image]
    )
  end

  def swap_positions(first_record, second_record)
    return if second_record.nil?

    first_pos = first_record.position
    first_record.update!(position: second_record.position)
    second_record.update!(position: first_pos)
  end

  # 並び替え後の一覧を返す。Turbo Streamならその場で一覧部分だけ差し替え、
  # それ以外(JS無効など)は今まで通り一覧ページへリダイレクトする。
  def render_reordered_stories
    @stories = current_user.stories.order(:position, created_at: :desc)

    respond_to do |format|
      format.turbo_stream { render "refresh_list" }
      format.html { redirect_to stories_path }
    end
  end

  def next_position_for(user)
    (user.stories.maximum(:position) || 0) + 10
  end
end
# rubocop:enable Metrics/ClassLength
