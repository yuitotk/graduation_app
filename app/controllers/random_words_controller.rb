class RandomWordsController < ApplicationController
  before_action :require_login

  def pick
    return render_not_enough_words if RandomWord.noun.count < 1 || RandomWord.verb.count < 1

    @word1_pos = params[:word1_pos].presence || "noun"
    @word2_pos = params[:word2_pos].presence || "verb"
    @words = build_words
  end

  private

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
