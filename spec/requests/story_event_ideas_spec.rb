require 'rails_helper'

RSpec.describe "StoryEventIdeas", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/story_event_ideas/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/story_event_ideas/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/story_event_ideas/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/story_event_ideas/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/story_event_ideas/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
