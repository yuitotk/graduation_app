class RandomWordsController < ApplicationController
  before_action :require_login

  def pick
    return render_not_enough_words if RandomWord.count < 2

    @words = build_words
  end

  private

  def render_not_enough_words
    @message = "辞書ワードが2件未満です。seedを追加してください。"
    @words = []
  end

  def build_words
    used_words = []

    word1_record = selected_word(
      current_word: params[:word1].to_s.strip,
      locked: params[:lock_word1] == "1",
      used_words: used_words
    )
    used_words << word1_record.word

    word2_record = selected_word(
      current_word: params[:word2].to_s.strip,
      locked: params[:lock_word2] == "1",
      used_words: used_words
    )

    [word1_record, word2_record]
  end

  def selected_word(current_word:, locked:, used_words:)
    if locked && current_word.present?
      RandomWord.find_by(word: current_word) || random_word_excluding(used_words)
    else
      random_word_excluding(used_words)
    end
  end

  def random_word_excluding(excluded_words)
    random_sql =
      if ActiveRecord::Base.connection.adapter_name.downcase.include?("mysql")
        "RAND()"
      else
        "RANDOM()"
      end

    scope = RandomWord.all
    scope = scope.where.not(word: excluded_words) if excluded_words.any?
    scope.order(Arel.sql(random_sql)).first
  end
end
