# rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
require "rails_helper"

RSpec.describe "StoryEventIdeas", type: :request do
  let!(:user) do
    u = User.new(email: "test@example.com")
    u.password = "password"
    u.save!
    u
  end

  let!(:story) { user.stories.create!(title: "t", description: "d", position: 10) }
  let!(:event) { story.story_events.create!(title: "e", body: "b", position: 10) }

  describe "並び替え（PATCH .../move_up, move_down）" do
    let!(:idea_a) { event.story_event_ideas.create!(title: "詳細メモA", memo: "m", position: 1) }
    let!(:idea_b) { event.story_event_ideas.create!(title: "詳細メモB", memo: "m", position: 2) }

    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    it "html形式の場合、今まで通りイベント詳細へリダイレクトし、並びが入れ替わる" do
      patch move_up_story_story_event_story_event_idea_path(story, event, idea_b)

      expect(response).to redirect_to(story_story_event_path(story, event))
      expect(idea_a.reload.position).to eq(2)
      expect(idea_b.reload.position).to eq(1)
    end

    it "turbo_stream形式の場合、その場で更新するレスポンスが返り、並びが入れ替わる" do
      patch move_up_story_story_event_story_event_idea_path(story, event, idea_b),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(idea_a.reload.position).to eq(2)
      expect(idea_b.reload.position).to eq(1)
    end

    it "move_downでも同様に並びが入れ替わる" do
      patch move_down_story_story_event_story_event_idea_path(story, event, idea_a)

      expect(response).to redirect_to(story_story_event_path(story, event))
      expect(idea_a.reload.position).to eq(2)
      expect(idea_b.reload.position).to eq(1)
    end
  end

  describe "並び替えの境界ケース（一番上/一番下をさらに動かそうとした場合）" do
    let!(:idea_a) { event.story_event_ideas.create!(title: "詳細メモA", memo: "m", position: 1) }
    let!(:idea_b) { event.story_event_ideas.create!(title: "詳細メモB", memo: "m", position: 2) }

    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    it "一番上のものをさらに上に移動しても、turbo_stream形式ならその場で更新するレスポンスが返る" do
      patch move_up_story_story_event_story_event_idea_path(story, event, idea_a),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(idea_a.reload.position).to eq(1)
      expect(idea_b.reload.position).to eq(2)
    end

    it "一番下のものをさらに下に移動しても、turbo_stream形式ならその場で更新するレスポンスが返る" do
      patch move_down_story_story_event_story_event_idea_path(story, event, idea_b),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(idea_a.reload.position).to eq(1)
      expect(idea_b.reload.position).to eq(2)
    end

    it "境界ケースのhtml形式では、今まで通り並び替え通知(「並び替えました」)が出ずにリダイレクトする" do
      patch move_up_story_story_event_story_event_idea_path(story, event, idea_a)

      expect(response).to redirect_to(story_story_event_path(story, event))
      expect(flash[:notice]).not_to eq(I18n.t("flash.story_event_ideas.reordered"))
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
