# rubocop:disable RSpec/MultipleExpectations
require "rails_helper"

RSpec.describe Ai::IdeaGenerator, type: :service do
  # OpenAIへ本物の通信をしないように、Faraday標準のテスト用アダプタで差し替える。
  # statuses に並べた順番で、リクエストのたびに違うレスポンスを返す。
  def stub_connection(statuses)
    call_count = 0

    Faraday.new do |f|
      f.request :json
      f.response :json
      f.adapter :test do |stub|
        stub.post("https://api.openai.com/v1/responses") do |_env|
          status = statuses[call_count]
          call_count += 1

          body =
            if status == 200
              { output: [{ type: "message", content: [{ type: "output_text", text: "生成結果" }] }] }
            else
              { error: "dummy" }
            end

          [status, { "Content-Type" => "application/json" }, body.to_json]
        end
      end
    end
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("OPENAI_API_KEY").and_return("test-key")
    allow(described_class).to receive(:sleep) # テストを遅くしないためリトライ待機を無効化
  end

  def call_generator
    described_class.call(word1: "うさぎ", word2: "走る", word1_pos: "noun", word2_pos: "verb")
  end

  it "1回で成功する場合、そのままリトライせずに結果を返す" do
    conn = stub_connection([200])
    allow(described_class).to receive(:connection).and_return(conn)

    expect(call_generator).to eq("生成結果")
    expect(described_class).not_to have_received(:sleep)
  end

  it "一時的な失敗(500)の後に成功すれば、リトライして結果を返す" do
    conn = stub_connection([500, 200])
    allow(described_class).to receive(:connection).and_return(conn)

    expect(call_generator).to eq("生成結果")
    expect(described_class).to have_received(:sleep).once
  end

  it "認証エラー(401)などは回復しないので、リトライせずすぐに例外を投げる" do
    conn = stub_connection([401])
    allow(described_class).to receive(:connection).and_return(conn)

    expect { call_generator }.to raise_error(/OpenAI error: 401/)
    expect(described_class).not_to have_received(:sleep)
  end

  it "5xxが上限まで続く場合は、リトライした上で最終的に例外を投げる" do
    conn = stub_connection([500, 500, 500])
    allow(described_class).to receive(:connection).and_return(conn)

    expect { call_generator }.to raise_error(/OpenAI error: 500/)
    expect(described_class).to have_received(:sleep).twice
  end
end
# rubocop:enable RSpec/MultipleExpectations
