require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /terms" do
    it "returns http success" do
      get "/terms"
      expect(response).to have_http_status(:success)
    end
  end
end
