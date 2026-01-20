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
    render :create
  rescue => e
    Rails.logger.error("[AI_GENERATE] #{e.class}: #{e.message}")
    @error = "生成に失敗しました。時間をおいてもう一度試してください。"
    render :create, status: :unprocessable_entity
  end
end
