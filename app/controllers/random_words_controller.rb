# rubocop:disable Metrics/ClassLength
class RandomWordsController < ApplicationController
  before_action :require_login
  before_action :set_breadcrumbs, only: %i[pick]

  def pick
    return render_not_enough_words if RandomWord.noun.count < 1 || RandomWord.verb.count < 1

    @word1_pos = params[:word1_pos].presence || "noun"
    @word2_pos = params[:word2_pos].presence || "verb"
    @words = build_words
  end

  private

  def set_breadcrumbs
    placeable = find_placeable_for_current_user(params[:placeable_type], params[:placeable_id])
    @breadcrumbs = breadcrumb_items_for_placeable(placeable)
  end

  def breadcrumb_items_for_placeable(placeable)
    case placeable
    when Story
      story_breadcrumbs(placeable)
    when StoryEvent
      story_event_breadcrumbs(placeable)
    when StoryEventIdea
      story_event_idea_breadcrumbs(placeable)
    when StoryElement
      story_element_breadcrumbs(placeable)
    else
      []
    end
  end

  def story_breadcrumbs(story)
    [
      { name: story.title, path: nil }
    ]
  end

  def story_event_breadcrumbs(story_event)
    story = story_event.story
    [
      { name: story.title, path: story_path(story) },
      { name: story_event.title, path: nil }
    ]
  end

  def story_event_idea_breadcrumbs(story_event_idea)
    story_event = story_event_idea.story_event
    story = story_event.story

    [
      { name: story.title, path: story_path(story) },
      { name: story_event.title, path: story_story_event_path(story, story_event) },
      { name: story_event_idea.title, path: nil }
    ]
  end

  def story_element_breadcrumbs(story_element)
    story = story_element.story

    [
      { name: story.title, path: story_path(story) },
      { name: "要素一覧", path: story_story_elements_path(story) },
      { name: story_element.name, path: nil }
    ]
  end

  def find_placeable_for_current_user(type, id)
    case type.to_s
    when "Story"
      current_user.stories.find_by(id: id)
    when "StoryEvent"
      StoryEvent.joins(:story).where(stories: { user_id: current_user.id }).find_by(id: id)
    when "StoryElement"
      StoryElement.joins(:story).where(stories: { user_id: current_user.id }).find_by(id: id)
    when "StoryEventIdea"
      StoryEventIdea.joins(story_event: :story).where(stories: { user_id: current_user.id }).find_by(id: id)
    end
  end

  def render_not_enough_words
    @message = "名詞と動詞の辞書ワードがそれぞれ1件以上必要です。seedを追加してください。"
    @words = []
  end

  def build_words
    used_words = []

    word1_record = selected_word(
      current_word: params[:word1].to_s.strip,
      current_pos: @word1_pos,
      locked: params[:lock_word1] == "1",
      used_words: used_words
    )
    used_words << word1_record.word if word1_record.present?

    word2_record = selected_word(
      current_word: params[:word2].to_s.strip,
      current_pos: @word2_pos,
      locked: params[:lock_word2] == "1",
      used_words: used_words
    )

    [word1_record, word2_record]
  end

  def selected_word(current_word:, current_pos:, locked:, used_words:)
    if locked && current_word.present?
      RandomWord.find_by(word: current_word) || random_word_excluding(used_words, current_pos)
    else
      random_word_excluding(used_words, current_pos)
    end
  end

  def random_word_excluding(excluded_words, part_of_speech)
    random_sql =
      if ActiveRecord::Base.connection.adapter_name.downcase.include?("mysql")
        "RAND()"
      else
        "RANDOM()"
      end

    scope = RandomWord.public_send(normalize_part_of_speech(part_of_speech))
    scope = scope.where.not(word: excluded_words) if excluded_words.any?
    scope.order(Arel.sql(random_sql)).first
  end

  def normalize_part_of_speech(value)
    %w[noun verb].include?(value) ? value : "noun"
  end
end
# rubocop:enable Metrics/ClassLength
