# rubocop:disable RSpec/MultipleExpectations
require "rails_helper"

RSpec.describe "StoryEvents", type: :request do
  let!(:user) do
    u = User.new(email: "test@example.com")
    u.password = "password"
    u.save!
    u
  end

  let!(:story) { user.stories.create!(title: "t", description: "d", position: 10) }
  let!(:event) { story.story_events.create!(title: "e", body: "b", position: 10) }

  describe "GET /stories/:story_id/story_events/new" do
    it "redirects (login required)" do
      get new_story_story_event_path(story)
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /stories/:story_id/story_events/:id/edit" do
    it "redirects (login required)" do
      get edit_story_story_event_path(story, event)
      expect(response).to have_http_status(:found)
    end
  end

  describe "並び替え（PATCH .../move_up, move_down）" do
    let!(:event_a) { story.story_events.create!(title: "イベントA", body: "b", position: 100) }
    let!(:event_b) { story.story_events.create!(title: "イベントB", body: "b", position: 200) }

    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    it "html形式の場合、今まで通りストーリー詳細へリダイレクトし、並びが入れ替わる" do
      patch move_up_story_story_event_path(story, event_b)

      expect(response).to redirect_to(story_path(story))
      expect(event_a.reload.position).to eq(200)
      expect(event_b.reload.position).to eq(100)
    end

    it "turbo_stream形式の場合、その場で更新するレスポンスが返り、並びが入れ替わる" do
      patch move_up_story_story_event_path(story, event_b), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(event_a.reload.position).to eq(200)
      expect(event_b.reload.position).to eq(100)
    end

    it "move_downでも同様に並びが入れ替わる" do
      patch move_down_story_story_event_path(story, event_a)

      expect(response).to redirect_to(story_path(story))
      expect(event_a.reload.position).to eq(200)
      expect(event_b.reload.position).to eq(100)
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
