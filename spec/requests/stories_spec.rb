# rubocop:disable RSpec/MultipleExpectations
require "rails_helper"

RSpec.describe "Stories", type: :request do
  let!(:user) do
    u = User.new(email: "test@example.com")
    u.password = "password"
    u.save!
    u
  end

  let!(:story) { user.stories.create!(title: "t", description: "d", position: 10) }

  describe "GET /stories" do
    it "redirects (login required)" do
      get stories_path
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /stories/:id" do
    it "redirects (login required)" do
      get story_path(story)
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /stories/new" do
    it "redirects (login required)" do
      get new_story_path
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /stories/:id/edit" do
    it "redirects (login required)" do
      get edit_story_path(story)
      expect(response).to have_http_status(:found)
    end
  end

  describe "並び替え（PATCH /stories/:id/move_up, move_down）" do
    let!(:story_a) { user.stories.create!(title: "ストーリーA", description: "d", position: 100) }
    let!(:story_b) { user.stories.create!(title: "ストーリーB", description: "d", position: 200) }

    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    it "html形式の場合、今まで通り一覧へリダイレクトし、並びが入れ替わる" do
      patch move_up_story_path(story_b)

      expect(response).to redirect_to(stories_path)
      expect(story_a.reload.position).to eq(200)
      expect(story_b.reload.position).to eq(100)
    end

    it "turbo_stream形式の場合、その場で更新するレスポンスが返り、並びが入れ替わる" do
      patch move_up_story_path(story_b), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(story_a.reload.position).to eq(200)
      expect(story_b.reload.position).to eq(100)
    end

    it "move_downでも同様に並びが入れ替わる" do
      patch move_down_story_path(story_a)

      expect(response).to redirect_to(stories_path)
      expect(story_a.reload.position).to eq(200)
      expect(story_b.reload.position).to eq(100)
    end
  end

  describe "DELETE /stories/:id" do
    let!(:story_to_delete) { user.stories.create!(title: "削除対象ストーリー", description: "d", position: 300) }

    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    # 削除ボタンは一覧ではなく編集画面にあり、削除後は一覧へ画面遷移する必要がある
    # (その場に留まる、という選択肢が無い)ため、turbo_stream対応はしていない。
    it "一覧へリダイレクトし、削除される" do
      delete story_path(story_to_delete)

      expect(response).to redirect_to(stories_path)
      expect(Story.exists?(story_to_delete.id)).to be false
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
