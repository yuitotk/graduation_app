require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let!(:user) do
    u = User.new(email: "reset_test@example.com")
    u.reset_password_token = "token123"
    u.reset_password_token_expires_at = 1.hour.from_now
    u.save!(validate: false)
    u
  end

  describe "GET /password_resets/new" do
    it "returns success" do
      get new_password_reset_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /password_resets" do
    it "redirects" do
      post password_resets_path, params: { email: user.email }
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /password_resets/:id/edit" do
    it "returns success" do
      get edit_password_reset_path(user.reset_password_token)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /password_resets/:id" do
    it "redirects" do
      patch password_reset_path(user.reset_password_token),
            params: { user: { password: "newpassword", password_confirmation: "newpassword" } }
      expect(response).to have_http_status(:found)
    end
  end
end
