require "rails_helper"

RSpec.describe "IdeaPlacements", type: :request do
  describe "POST /ideas/:idea_id/idea_placement" do
    it "redirects to login when not logged in" do
      post "/ideas/1/idea_placement",
           params: { placeable_type: "Story", placeable_id: 1 }

      expect(response).to have_http_status(:redirect)
      # ログイン画面に飛ぶことまで確認したければ（任意）
      # expect(response).to redirect_to(login_path)
    end
  end
end
