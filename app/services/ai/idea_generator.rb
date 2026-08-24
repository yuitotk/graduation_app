# frozen_string_literal: true

require "faraday"
require "json"

module Ai
  class IdeaGenerator
    ENDPOINT = "https://api.openai.com/v1/responses"

    # 一時的な失敗(通信エラー・タイムアウト・429/5xx)だけ、間隔を空けて
    # 合計MAX_ATTEMPTS回まで試行する。認証エラーなど何度やっても直らない
    # 失敗(401など)はリトライせず、すぐに諦める。
    MAX_ATTEMPTS = 3
    RETRY_WAIT_SECONDS = 1

    def self.call(word1:, word2:, word1_pos:, word2_pos:)
      raise "OPENAI_API_KEY is missing" if ENV["OPENAI_API_KEY"].to_s.strip.empty?

      prompt = build_prompt(word1: word1, word2: word2, word1_pos: word1_pos, word2_pos: word2_pos)
      res = request_with_retry(prompt)

      raise "OpenAI error: #{res.status} #{res.body}" unless res.success?

      extract_text(res.body)
    end

    def self.build_prompt(word1:, word2:, word1_pos:, word2_pos:)
      <<~TEXT
        次の2語を必ず使って、物語のタネになる短いアイデア文を日本語で作ってください。
        ・2〜4文
        ・説明は不要
        ・それぞれ指定された品詞の役割を意識して使うこと

        1) #{word1}（#{part_of_speech_label(word1_pos)}）
        2) #{word2}（#{part_of_speech_label(word2_pos)}）
      TEXT
    end

    def self.connection
      Faraday.new do |f|
        f.request :json
        f.response :json
      end
    end

    def self.post_request(conn, prompt)
      conn.post(ENDPOINT) do |req|
        req.headers["Authorization"] = "Bearer #{ENV['OPENAI_API_KEY']}"
        req.headers["Content-Type"] = "application/json"
        req.body = {
          model: "gpt-5.2",
          input: prompt,
          store: false
        }
      end
    end

    def self.request_with_retry(prompt)
      conn = connection
      last_response = nil
      last_error = nil

      MAX_ATTEMPTS.times do |attempt|
        begin
          last_response = post_request(conn, prompt)
          return last_response if last_response.success? || !retryable_status?(last_response.status)

          last_error = nil
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
          last_error = e
          last_response = nil
        end

        sleep(RETRY_WAIT_SECONDS) if attempt < MAX_ATTEMPTS - 1
      end

      raise last_error if last_error

      last_response
    end

    def self.retryable_status?(status)
      status == 429 || (500..599).cover?(status)
    end

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

    private_class_method :build_prompt, :connection, :post_request, :request_with_retry,
                         :retryable_status?, :extract_text, :part_of_speech_label
  end
end
