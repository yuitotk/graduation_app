Rails.application.routes.draw do
  get 'user_sessions/new'
  root "tops#top"

  # 静的ページ
  get "/terms",   to: "static_pages#terms",   as: :terms
  get "/privacy", to: "static_pages#privacy", as: :privacy

  # ユーザー登録
  get  "/signup", to: "users#new"
  post "/signup", to: "users#create"

  # ログイン
  get    "/login",  to: "user_sessions#new"
  post   "/login",  to: "user_sessions#create"
  delete "/logout", to: "user_sessions#destroy"

  resources :ideas, only: %i[index show new create edit update destroy]
  get "random_words/pick", to: "random_words#pick"

  resources :ai_generations, only: [:create] do
    post :save, on: :collection
  end
end
