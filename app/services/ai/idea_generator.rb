# frozen_string_literal: true

require "faraday"
require "json"

module Ai
  class IdeaGenerator
    ENDPOINT = "https://api.openai.com/v1/responses"

    def self.call(word1:, word2:)
      raise "OPENAI_API_KEY is missing" if ENV["OPENAI_API_KEY"].to_s.strip.empty?

      prompt = <<~TEXT
        次の2語を必ず使って、物語のタネになる短いアイデア文を日本語で作ってください。
        ・2〜4文
        ・説明は不要

        1) #{word1}
        2) #{word2}
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

    def self.extract_text(body)
      # Responses APIは output 配列に message / output_text などが入る想定。
      # SDKなら response.output_text で集約されるが、Rubyは自前で拾う。:contentReference[oaicite:3]{index=3}
      output = body["output"] || []

      message = output.find { |x| x["type"] == "message" }
      if message
        parts = message["content"] || []
        text = parts.find { |p| p["type"] == "output_text" }&.dig("text")
        return text.to_s.strip if text.present?
      end

      # フォールバック（形が違う時）
      text = output.dig(0, "content", 0, "text")
      text.to_s.strip
    end

    private_class_method :extract_text
  end
end
