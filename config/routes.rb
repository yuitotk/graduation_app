# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
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

  # パスワードリセット
  resources :password_resets, only: %i[new create edit update]

  # アイデア
  resources :ideas, only: %i[index show new create edit update destroy]

  # ストーリー（時系列）
  resources :stories do
    member do
      get :consistency
      patch :move_up
      patch :move_down
    end

    # ✅ 要素（キャラ/アイテム/設定）
    resources :story_elements, except: %i[show]

    resources :story_events, except: %i[index] do
      member do
        patch :move_up
        patch :move_down
      end

      # ✅ イベント詳細メモ（アイデア形式）＋ 並び替え
      resources :story_event_ideas, only: %i[new create edit update destroy] do
        member do
          patch :move_up
          patch :move_down
        end
      end
    end
  end

  # お問い合わせ（入力→確認→完了）
  resources :inquiries, only: %i[new create] do
    post :confirm, on: :collection
    get  :done,    on: :collection
  end

  # 辞書ワード2語表示（再抽選）
  get "random_words/pick", to: "random_words#pick"

  # AI生成
  resources :ai_generations, only: [:create] do
    post :save, on: :collection
  end
end
# rubocop:enable Metrics/BlockLength
