require "rails_helper"

RSpec.describe "Ideas", type: :request do
  it "未ログインだと /ideas はリダイレクトされる" do
    get ideas_path
    expect(response).to have_http_status(:found) # 302
  end

  it "ログイン済みだと /ideas が表示できる" do
    user = create(:user, password: "password")

    post login_path, params: { email: user.email, password: "password" }

    get ideas_path
    expect(response).to have_http_status(:ok) # 200
  end

  it "ログイン後、アイデアを作成できる" do
    user = create(:user, password: "password")
    post login_path, params: { email: user.email, password: "password" }

    post ideas_path, params: { idea: { title: "t", memo: "m" } }

    expect(response).to have_http_status(:found) # 302（作成後リダイレクト）
  end
end
