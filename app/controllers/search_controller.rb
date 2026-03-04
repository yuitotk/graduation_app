# app/controllers/search_controller.rb
class SearchController < ApplicationController
  before_action :require_login

  # rubocop:disable Metrics/AbcSize
  def index
    @query        = params[:q].to_s.strip
    @scope        = normalize_scope(params[:scope])
    @within_story = params[:within_story].to_s == "1"
    @story_id     = params[:story_id].presence&.to_i
    @story        = @within_story && @story_id ? current_user.stories.find_by(id: @story_id) : nil

    # ✅ 追加: 検索前に戻る用（/search を保存しない＝無限ループ防止）
    rt = safe_path(params[:return_to])
    session[:search_return_to] = rt if rt.present? && !rt.start_with?("/search")

    sync_search_story_session(within_story: @within_story, story_id: @story_id)

    # 空検索は結果を出さない（仕様：空なら候補も本検索もしない）
    if @query.blank?
      @results = {}
      return
    end

    # 「この作品内」ONのときだけ story_id をサービスに渡す（OFFなら nil）
    service_story_id = @within_story ? @story_id : nil

    @results =
      Search::Query.new(
        q: @query,
        scope: @scope,
        story_id: service_story_id,
        user: current_user
      ).call
  end
  # rubocop:enable Metrics/AbcSize

  def suggestions
    q            = params[:q].to_s.strip
    scope        = normalize_scope(params[:scope])
    within_story = params[:within_story].to_s == "1"
    story_id     = params[:story_id].presence&.to_i

    return render(json: {}) if q.blank?

    service_story_id = within_story ? story_id : nil

    suggestions =
      Search::Suggestions.new(
        q: q,
        scope: scope,
        story_id: service_story_id,
        user: current_user
      ).call

    render json: suggestions
  end

  private

  # ✅ 追加: return_to は「/ から始まるパス」だけ許可（安全対策）
  def safe_path(value)
    v = value.to_s
    v.start_with?("/") ? v : nil
  end

  def normalize_scope(scope_param)
    s = scope_param.to_s
    return "all" if s.blank?

    valid = %w[all home story event element]
    return "all" unless valid.include?(s)

    s
  end

  # ✅ OFFで検索しても story_id を消さない（検索結果ページでチェックUIを残すため）
  def sync_search_story_session(within_story:, story_id:)
    session[:search_story_id] = story_id if story_id.present?
    session[:search_in_story] = within_story && story_id.present?
  end
end
