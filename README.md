[![CI](https://github.com/yuitotk/graduation_app/actions/workflows/ci.yml/badge.svg)](https://github.com/yuitotk/graduation_app/actions/workflows/ci.yml)

# 創記録（graduation_app）

写真付きメモ形式の「アイデア」を蓄積し、辞書ワードのペア（2語）を組み合わせたAIによる発想支援と、
物語のイベント・登場要素を時系列で管理できる創作支援サービスです。

## サービス概要

- **対象ユーザー**：漫画・小説など、物語を作っている人（10〜30代）
- **解決したい課題**
  - アイデアが散らかる
  - 発想が止まる
  - キャラ・アイテムの登場箇所が追えない

## 開発の背景

高校2年生のときに漫画を作ろうとした経験がきっかけです。当時は一般的なメモアプリでアイデアやストーリー、
キャラクターの設定を記録していましたが、情報が増えるほど必要な内容を探しにくくなったり、ストーリーの
流れや「このキャラは今どこにいるか」といった状況を確認しづらくなったりしました。

そこで、物語のアイデア・キャラクターや設定・出来事を一つの場所で整理し、ストーリーの流れも確認できる
サービスがあれば創作をしやすくできると考え、開発しました。あわせて、自分自身がアイデアに詰まることも
多かったため、ランダムな2つの言葉を組み合わせて発想のきっかけを作る「ペアアイデア」と、その組み合わせを
もとにAIが物語のアイデアを提案する機能も取り入れています。AIが作品を作るのではなく、あくまでユーザー
自身が物語を考えるための補助として使えることを意識しました。

## ER図

![Image from Gyazo](https://i.gyazo.com/93ea90dd54a318fe1a80ebc74205a6df.png)

## 画面遷移図

Figma：https://www.figma.com/board/PpIwMCpGPlmi68IROYUKwE/%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0-1&t=boAFElvQfy15jxo0-1

## 主な機能

1. アイデア投稿・管理（タイトル・メモ・画像1枚）
2. アイデア配置（ストーリー／イベント／要素／詳細メモへの紐づけ）
3. 辞書×AI発想（「ペアアイデア」：ランダムな辞書単語2語 → AI生成 → アイデアとして保存）
4. ストーリー管理（並び替え可能、画像1枚）
5. ストーリーイベント管理
6. 要素管理（キャラクター／アイテム／設定）
7. イベント×要素の多対多紐づけ
8. イベント内の詳細メモ管理
9. 整合性チェック（選んだ要素が関わるイベントだけを時系列で表示）
10. 検索（アイデアのタイトル・メモをLIKE検索、サジェスト付き）
11. ユーザー認証（新規登録／ログイン／ログアウト／パスワードリセット）
12. お問い合わせ（入力→確認→完了）

## 使い方の流れ

1. トップページ（`/`）から新規登録、またはログイン
2. ログイン後は「アイデア一覧」（`/ideas`）がホーム画面。配置先が未設定のアイデアが並ぶ
3. 思いついたことを「アイデア」として投稿（タイトル・メモ・画像1枚）
   - もしくは「ペアアイデア」（`/random_words/pick`）でランダムな辞書2語からAIに物語のアイデアを提案してもらい、保存
4. 「ストーリー」を作成し、その中に「イベント（出来事）」を時系列で登録
5. 「要素」としてキャラクター・アイテム・設定を登録し、イベントに紐づけ
6. イベントごとに「詳細メモ」を追加して内容を深掘り
7. 「整合性チェック」で、特定の要素を選ぶとその要素が関わる場面だけを時系列で確認
8. 困ったときは検索（`/search`）でアイデア・ストーリー内のメモを横断検索

## 使用技術

| 分類 | 技術 |
| --- | --- |
| 言語 / フレームワーク | Ruby 3.1.4 / Ruby on Rails 7.0.10 |
| データベース | MySQL 8.0 |
| フロントエンド | Hotwire（Turbo + Stimulus）、importmap-rails |
| アプリケーションサーバー | Puma |
| 認証 | sorcery |
| 画像アップロード | carrierwave + Cloudinary |
| AI連携 | OpenAI API（faraday経由でHTTPリクエスト） |
| テスト / 静的解析 | RSpec、RuboCop |
| 開発環境 | Docker / Docker Compose |

## 外部サービス

- **OpenAI API**：ペアアイデアの2語から物語のアイデアを生成
- **Cloudinary**：本番環境での画像ストレージ
- **Gmail SMTP**：パスワードリセットメールの送信

## デプロイ・開発環境

- **本番**：Render上で稼働（`bin/render-build.sh` で `bundle install` → `assets:precompile` → `assets:clean` → `db:migrate`）
- **ローカル**：Docker Compose（`web` = Rails / `port 3000`、`db` = MySQL 8.0）

### ローカルでの起動方法

```bash
docker compose up
```

初回起動時は `bundle install` とDB作成が必要です。

```bash
docker compose run --rm web bin/rails db:setup
```

`http://localhost:3000` でアクセスできます。AI発想機能を使う場合は、`.env` に `OPENAI_API_KEY` を設定してください。

### テスト・静的解析の実行

```bash
docker compose exec web bundle exec rspec
docker compose exec web bundle exec rubocop
```
