class AiGenerationsController < ApplicationController
  def create
    word1 = params[:word1].to_s.strip
    word2 = params[:word2].to_s.strip

    if word1.blank? || word2.blank?
      @error = "2語が取得できませんでした。もう一度やり直してください。"
      return render :create, status: :unprocessable_entity
    end

    @text = Ai::IdeaGenerator.call(word1: word1, word2: word2)
    @error = ""
    @word1 = word1
    @word2 = word2

    render :create
  rescue => e
    Rails.logger.error("[AI_GENERATE] #{e.class}: #{e.message}")
    @error = "生成に失敗しました。時間をおいてもう一度試してください。"
    render :create, status: :unprocessable_entity
  end

  def save
    text  = params[:generated_text].to_s
    word1 = params[:word1].to_s
    word2 = params[:word2].to_s

    memo = text
    memo = "元ワード: #{word1} / #{word2}\n\n#{text}" if word1.present? && word2.present? # 任意

    idea = current_user.ideas.build(
      title: "#{word1}×#{word2}".presence || "AI生成アイデア",
      memo: memo
    )

    if idea.save
      redirect_to idea_path(idea), notice: "アイデアを保存しました"
    else
      redirect_back fallback_location: random_words_pick_path, alert: "保存に失敗しました"
    end
  end
end
