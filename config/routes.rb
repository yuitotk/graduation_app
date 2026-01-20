Rails.application.routes.draw do
  get 'ai_generations/create'
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
  resources :ideas, only: %i[index show new create edit update destroy]

  # 辞書ワード2語表示（再抽選）
  get "random_words/pick", to: "random_words#pick"

  resources :ai_generations, only: [:create]
end
