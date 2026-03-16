# rubocop:disable Metrics/ClassLength
class AiGenerationsController < ApplicationController
  before_action :require_login

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    store_ai_context
    prepare_marker_select_for_ai

    word1 = params[:word1].to_s.strip
    word2 = params[:word2].to_s.strip
    word1_pos = normalize_part_of_speech(params[:word1_pos], default: "noun")
    word2_pos = normalize_part_of_speech(params[:word2_pos], default: "verb")

    if word1.blank? || word2.blank?
      @error = "2語が取得できませんでした。もう一度やり直してください。"
      return render :create, status: :unprocessable_entity
    end

    @text = Ai::IdeaGenerator.call(
      word1: word1,
      word2: word2,
      word1_pos: word1_pos,
      word2_pos: word2_pos
    )
    @error = ""
    @word1 = word1
    @word2 = word2
    @word1_pos = word1_pos
    @word2_pos = word2_pos
    @lock_word1 = params[:lock_word1] == "1"
    @lock_word2 = params[:lock_word2] == "1"

    @return_to      = ai_return_to
    @placeable_type = ai_placeable_type
    @placeable_id   = ai_placeable_id

    render :create
  rescue StandardError => e
    Rails.logger.error("[AI_GENERATE] #{e.class}: #{e.message}")
    @error = "生成に失敗しました。時間をおいてもう一度試してください。"
    render :create, status: :unprocessable_entity
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def save
    text  = params[:memo].to_s
    word1 = params[:word1].to_s
    word2 = params[:word2].to_s

    idea = current_user.ideas.build(
      title: "#{word1}×#{word2}".presence || "AI生成アイデア",
      memo: text
    )

    if idea.save
      attach_placement_if_needed(idea, created_here: true, marker: placement_marker_param)

      return_to =
        if params[:return_to].present?
          safe_path(params[:return_to])
        else
          ideas_path
        end

      redirect_to(return_to || idea_path(idea), notice: "アイデアを保存しました")
    else
      redirect_back fallback_location: ai_return_to || random_words_pick_path,
                    alert: "保存に失敗しました"
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  # rubocop:disable Metrics/AbcSize
  def store_ai_context
    rt = safe_path(params[:return_to])
    session[:ai_return_to] = rt if rt.present?

    session[:ai_return_to] = ideas_path if rt.blank? && params[:placeable_type].blank? && params[:placeable_id].blank?

    if params[:placeable_type].present? && params[:placeable_id].present?
      session[:ai_placeable_type] = params[:placeable_type].to_s
      session[:ai_placeable_id]   = params[:placeable_id].to_s
    else
      session[:ai_placeable_type] = nil
      session[:ai_placeable_id]   = nil
    end
  end
  # rubocop:enable Metrics/AbcSize

  def ai_return_to
    safe_path(params[:return_to]) || session[:ai_return_to]
  end

  def ai_placeable_type
    params[:placeable_type].presence || session[:ai_placeable_type]
  end

  def ai_placeable_id
    params[:placeable_id].presence || session[:ai_placeable_id]
  end

  def safe_path(value)
    v = value.to_s
    v.start_with?("/") ? v : nil
  end

  def placement_marker_param
    return nil unless params.key?(:placement_marker)

    params[:placement_marker].presence
  end

  def attach_placement_if_needed(idea, created_here:, marker: nil)
    return if idea.idea_placement.present?

    type = ai_placeable_type.to_s
    id   = ai_placeable_id.to_s
    return if type.blank? || id.blank?

    placeable = find_placeable_for_current_user(type, id)
    return if placeable.nil?

    idea.create_idea_placement!(placeable: placeable, created_here: created_here, marker: marker)
  end

  def find_placeable_for_current_user(type, id)
    case type
    when "Story"
      current_user.stories.find_by(id: id)
    when "StoryEvent"
      StoryEvent.joins(:story).where(stories: { user_id: current_user.id }).find_by(id: id)
    when "StoryElement"
      StoryElement.joins(:story).where(stories: { user_id: current_user.id }).find_by(id: id)
    end
  end

  def prepare_marker_select_for_ai
    placeable = find_placeable_for_current_user(ai_placeable_type.to_s, ai_placeable_id.to_s)

    if placeable
      story = story_for_placeable(placeable)
      @marker_options = marker_options_for_story(story)
      @selected_marker = nil
      @show_marker_select = true
    else
      @marker_options = []
      @selected_marker = nil
      @show_marker_select = false
    end
  end

  def story_for_placeable(placeable)
    case placeable
    when Story
      placeable
    when StoryEvent, StoryElement
      placeable.story
    end
  end

  def marker_options_for_story(story)
    return [] if story.nil?

    story.story_elements
         .where.not(marker: [nil, ""])
         .distinct
         .order(:marker)
         .pluck(:marker)
  end

  def normalize_part_of_speech(value, default:)
    %w[noun verb].include?(value.to_s) ? value.to_s : default
  end

  def part_of_speech_label(value)
    value == "verb" ? "動詞" : "名詞"
  end
end
# rubocop:enable Metrics/ClassLength
