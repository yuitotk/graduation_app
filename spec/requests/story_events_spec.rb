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
end
