# frozen_string_literal: true

require "faraday"
require "json"

module Ai
  class IdeaGenerator
    ENDPOINT = "https://api.openai.com/v1/responses"

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.call(word1:, word2:, word1_pos:, word2_pos:)
      raise "OPENAI_API_KEY is missing" if ENV["OPENAI_API_KEY"].to_s.strip.empty?

      prompt = <<~TEXT
        次の2語を必ず使って、物語のタネになる短いアイデア文を日本語で作ってください。
        ・2〜4文
        ・説明は不要
        ・それぞれ指定された品詞の役割を意識して使うこと

        1) #{word1}（#{part_of_speech_label(word1_pos)}）
        2) #{word2}（#{part_of_speech_label(word2_pos)}）
      TEXT

      conn = Faraday.new do |f|
        f.request :json
        f.response :json
      end

      res = conn.post(ENDPOINT) do |req|
        req.headers["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
        req.headers["Content-Type"] = "application/json"
        req.body = {
          model: "gpt-5.2",
          input: prompt,
          store: false
        }
      end

      raise "OpenAI error: #{res.status} #{res.body}" unless res.success?

      extract_text(res.body)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def self.extract_text(body)
      output = body["output"] || []

      message = output.find { |x| x["type"] == "message" }
      if message
        parts = message["content"] || []
        text = parts.find { |p| p["type"] == "output_text" }&.dig("text")
        return text.to_s.strip if text.present?
      end

      text = output.dig(0, "content", 0, "text")
      text.to_s.strip
    end

    def self.part_of_speech_label(value)
      value.to_s == "verb" ? "動詞" : "名詞"
    end

    private_class_method :extract_text, :part_of_speech_label
  end
end
