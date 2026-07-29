# CLAUDE.md

## サービス概要

### 目的
写真付きメモ形式の「アイデア」を蓄積し、辞書ワードのペア（2語）を組み合わせたAIによる発想支援と、
物語のイベント・登場要素を時系列で管理する創作支援サービス。

### 対象ユーザー
創作者（10〜30代）

### 解決したい問題
- アイデアが散らかる
- 発想が止まる
- キャラ・アイテムの登場箇所が追えない

## 主な画面とユーザーの流れ（config/routes.rb）

- ログイン前: トップ(`/`) → ログイン済なら`/ideas`へ自動リダイレクト
  (app/controllers/tops_controller.rb)。ログイン(`/login`)、新規登録(`/signup`)、
  パスワードリセット(`/password_resets`)
- ログイン後のホーム: `/ideas` — 配置先が未設定のアイデアだけが並ぶ
  (app/controllers/ideas_controller.rb)
- アイデア作成・編集・詳細: `/ideas/new`, `/ideas/:id/edit`, `/ideas/:id`
- 辞書×AI発想: `/random_words/pick` で単語抽選 → `/ai_generations` で生成
  → `save` でアイデア保存
  (app/controllers/random_words_controller.rb, app/controllers/ai_generations_controller.rb)
- ストーリー: `/stories`（一覧・新規・詳細・編集・整合性チェック）
  (app/controllers/stories_controller.rb)
- ストーリー配下のイベント: `/stories/:story_id/story_events/...`
  (app/controllers/story_events_controller.rb)
- イベント内の詳細メモ: `/stories/:story_id/story_events/:id/story_event_ideas/...`
  (app/controllers/story_event_ideas_controller.rb)
- ストーリー配下の要素（キャラ/アイテム/設定）: `/stories/:story_id/story_elements/...`
  (app/controllers/story_elements_controller.rb)
- 検索: `/search`, `/search/suggestions`
  (app/controllers/search_controller.rb)
- お問い合わせ: `/inquiries/new` → confirm → done
  (app/controllers/inquiries_controller.rb)
- 静的ページ: `/help`, `/terms`, `/privacy`
  (app/controllers/static_pages_controller.rb)

## 主要機能

1. アイデア投稿・管理（タイトル・メモ・画像1枚） — app/models/idea.rb, app/controllers/ideas_controller.rb
2. アイデア配置 — app/models/idea_placement.rb, app/controllers/idea_placements_controller.rb
3. 辞書×AI発想 — app/controllers/random_words_controller.rb, app/services/ai/idea_generator.rb
4. ストーリー管理（並び替え可能、画像1枚） — app/models/story.rb, app/controllers/stories_controller.rb
5. ストーリーイベント管理 — app/models/story_event.rb, app/controllers/story_events_controller.rb
6. 要素管理（キャラ/アイテム/設定） — app/models/story_element.rb, app/controllers/story_elements_controller.rb
7. イベント×要素の多対多紐付け — app/models/story_event_element.rb
8. イベント内の詳細メモ — app/models/story_event_idea.rb, app/controllers/story_event_ideas_controller.rb
9. 整合性チェック — app/controllers/stories_controller.rb (#consistency)
10. 検索（アイデアタイトル・メモをLIKE検索） — app/services/search/query.rb, app/services/search/suggestions.rb
11. ユーザー認証 — app/models/user.rb, config/initializers/sorcery.rb
12. お問い合わせ — app/models/inquiry.rb, app/controllers/inquiries_controller.rb

## 使用技術

- Ruby 3.1.4 / Rails 7.0.10（Gemfileの指定は `~> 7.0.4, >= 7.0.4.3`、実際のロック済みバージョンはGemfile.lock:267）
- MySQL 8.0（開発・本番とも。compose.ymlで`mysql:8.0`を指定、db/schema.rbのcollationも`utf8mb4_0900_ai_ci`でMySQL 8.0系。本番は`DATABASE_URL`経由で接続、config/database.yml）
- Hotwire (Turbo + Stimulus)、importmap-rails（Gemfile:29-35、config/importmap.rb）
- Puma（Gemfile:26）

※ README記載の「PostgreSQL（本番）」「Bootstrap5」はコード上に根拠が見当たりません。`pg` gemはproductionグループに存在しますが、config/database.ymlのproduction設定は`DATABASE_URL`依存のため実際のDB種別はコードからは断定できません。Bootstrap用gemやvendor/javascript配下にも該当ファイルはありません。

## 重要なモデルとDBテーブル（db/schema.rb）

- users / ideas / idea_images / idea_placements / idea_placement_elements
- stories / story_images / story_elements / story_element_images
- story_events / story_event_images / story_event_elements
- story_event_ideas / story_event_idea_elements
- random_words / inquiries

## DBテーブル同士の関連付け

- users 1-N ideas, stories, inquiries
- ideas 1-1 idea_images／1-1 idea_placements
- idea_placements は polymorphic（Story/StoryEvent/StoryElement/StoryEventIdeaのいずれか）
- idea_placements N-N story_elements（中間: idea_placement_elements）
- stories 1-N story_events, story_elements／1-1 story_images
- story_events 1-N story_event_ideas／1-1 story_event_images
- story_events N-N story_elements（中間: story_event_elements）
- story_event_ideas は idea へ任意で belongs_to（optional: true）
- story_event_ideas N-N story_elements（中間: story_event_idea_elements）
- story_elements 1-1 story_element_images

## 重要なGem

- sorcery — 認証（reset_passwordサブモジュールのみ有効化、config/initializers/sorcery.rb:7）
- carrierwave + cloudinary — 画像アップロード・外部ストレージ連携
  （config/initializers/carrierwave.rb, app/uploaders/idea_image_uploader.rb）
- faraday — OpenAI APIへのHTTPリクエスト（app/services/ai/idea_generator.rb:3）。
  Gemfileに直接の記載はないが、cloudinary gemの依存として導入されている（Gemfile.lock:107-110）
- turbo-rails / stimulus-rails — Hotwire、Turbo Streamでの部分更新
  （app/views/ai_generations/create.turbo_stream.erb）
- rspec-rails / factory_bot_rails / rubocop系 — テスト・静的解析。
  実際にテストが書かれているのは`spec/`（39ファイル）。`test/`（9ファイル）は
  `rails new`直後の空の初期生成物のまま未使用（例: test/models/user_test.rb）
- mysql2 / pg — DB接続

## 外部サービス

- OpenAI API（`https://api.openai.com/v1/responses`、モデル`gpt-5.2`、`OPENAI_API_KEY`環境変数、
  app/services/ai/idea_generator.rb:8-12）
- Cloudinary（画像ストレージ、本番のみ、`CLOUDINARY_URL`環境変数、config/initializers/carrierwave.rb:7）
- Gmail SMTP（パスワードリセットメール送信、`smtp.gmail.com:587`、`SMTP_USERNAME`/`SMTP_PASSWORD`環境変数、
  config/environments/production.rb:78-86）

## デプロイ環境

- Render上で稼働（本番ホスト名`graduation-app-hkc2.onrender.com`がデフォルト値としてコードに直書き、
  config/environments/production.rb:74）
- ビルドスクリプト bin/render-build.sh: `bundle install` → `assets:precompile` →
  `assets:clean` → `db:migrate`
- ローカル開発はDocker Compose（compose.yml）: `web`（Rails, ポート3000）+ `db`（MySQL 8.0）の
  2サービス構成。Dockerfileのベースは`ruby:3.1.4`

## このプロジェクトで守る作業ルール

- 実際のコードを確認して回答する。憶測では話さず、裏付けがあるもので話す。
- 回答時は関係するファイル名を示す。
- 明確に依頼されるまでファイルを変更しない。
- 変更前に、変更する内容を説明する。
