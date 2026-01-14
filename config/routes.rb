Rails.application.routes.draw do
  # ユーザー登録
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  root "tops#top"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
