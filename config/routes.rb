Rails.application.routes.draw do
  get 'user_sessions/new'
  root "tops#top"

  # ユーザー登録
  get  "/signup", to: "users#new"
  post "/signup", to: "users#create"

  # ログイン
  get    "/login",  to: "user_sessions#new"
  post   "/login",  to: "user_sessions#create"
  delete "/logout", to: "user_sessions#destroy"

  # アイデア（一覧＝ホーム）
  resources :ideas, only: [:index, :new, :create, :show]
end
