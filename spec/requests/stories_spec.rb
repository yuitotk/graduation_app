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
end
