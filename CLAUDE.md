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

### なぜこのサービスを作ったか（開発の原体験）

**誰が困っている？**
漫画や小説など、物語を作っている人

**何に困っている？**
- アイデアや設定が増えると、必要な情報を見つけにくい
- ストーリーの流れや順番が分かりにくくなる
- 「この場面で、このキャラクターはどこにいるか」など、人物や設定の状況を確認しにくい
- 一般的なメモアプリでは、物語用の情報を整理して管理しづらい
- アイデアが出てこない

**なぜこのサービスを作ったか**
高校2年生のときに漫画を作ろうとした経験が、創記録を開発するきっかけです。
当時は一般的なメモアプリを使って、思いついたアイデアやストーリー、キャラクターの設定などを記録していました。
しかし、情報が増えていくと、必要な情報を見やすい場所にまとめられず、あとからすぐに探せないという不便がありました。また、ストーリーの流れや順番が分かりにくくなったり、「この場面のとき、このキャラクターはどこにいるのか」といった設定を確認することも難しくなりました。
そこで、物語のアイデア・キャラクターや設定・出来事などを一つの場所で整理し、ストーリーの流れも確認できるサービスがあれば、創作をしやすくできると考えました。
さらに、自分自身がアイデアを思いつかず困ることもあったため、創記録には発想を助ける機能も取り入れました。
その一つが「ペアアイデア」で、ランダムに選ばれた2つの言葉を組み合わせ、普段は思いつかないような発想のきっかけを作る機能です。さらに、その組み合わせをもとにAIから物語のアイデアを提案してもらえるようにし、AIが作品を作るのではなく、ユーザー自身が物語を考えるための補助として使えるようにしました。
このように、自分が漫画制作をしていたときに感じた「情報を整理しにくい」「ストーリーの状況を確認しにくい」「アイデアが思いつかない」という課題を解決し、物語を作る人がより創作に集中できるサービスを作りたいと思ったことが、創記録を開発した理由です。

## サービスの説明（面接用・3分説明）

面接で「もう少し詳しく説明してください」と言われた時用の、サービスの大まかな流れ。

### ① サービスを一言で

創記録は、漫画や小説などの物語を作る人が、設定や出来事を整理しながら、アイデアの発想も支援できる創作支援サービスです。

### ② 誰の・どんな課題を解決するか

創記録は、漫画や小説など、物語を作っている人が対象です。

物語を作っていると、アイデアや設定、出来事が増えるにつれて、必要な情報を整理したり探したりすることが難しくなります。物語が長くなるほど、出来事の順番や「この場面で、このキャラクターはどこにいるのか」といった状況も把握しづらくなります。

もう一つの課題は、物語を考えている途中でアイデアが思いつかず、制作が止まってしまうことです。

創記録は、こうした「物語の情報を整理・確認しにくい」「アイデアが出ず制作が止まる」という2つの課題を解決することを目指しています。

### ③ なぜ作ったか

開発のきっかけは、私自身が高校2年生のときに漫画を作ろうとした経験です。

当時は一般的なメモアプリに、アイデアやキャラクター設定、ストーリーなどを記録していました。

ただ、情報が増えるにつれて、必要な内容を後から探しにくくなったり、物語の流れやキャラクターの状況を確認しづらくなったりしました。

また、物語を考えている途中でアイデアが思いつかず、制作が止まってしまうこともありました。

そこで、物語に必要な情報を整理して確認しやすくし、アイデアが出ないときには発想のきっかけも得られるサービスがあれば、自分が感じていた不便を解決できると考えました。

この経験が、「創記録」を作ろうと思った理由です。

### ④ 主要機能

主要な機能は、大きく3つあります。

1つ目は、**物語の流れを整理する機能**です。

作品ごとに「ストーリー」を作り、その中に出来事を「イベント、詳細メモ」として登録することで、物語の出来事を順番に整理できます。

2つ目は、**登場人物や設定と、物語の出来事を関連付けて確認する機能**です。

登場人物・アイテム・世界観などを「要素」として登録し、イベントなどと紐付けることができます。

例えば特定のキャラクターを選ぶと、そのキャラクターが関係している場面だけを整合性チェックで時系列で確認できるため、物語の中での動きや関係を追いやすくしています。

3つ目は、**アイデアの発想を支援する機能**です。

「ペアアイデア」では、ランダムに表示された2つの辞書単語を組み合わせて、普段とは違う方向からアイデアを考えるきっかけを作れます。

さらに、その2つの単語をもとに、AIから物語のアイデアを提案してもらうこともできます。

### ⑤ 特に工夫した・特徴的なところ

工夫した点は、登場人物や設定などの「要素」と物語の出来事を紐付け、その情報を検索や確認など複数の機能で活用できるようにしたことです。

AIについては、物語そのものを完成させるのではなく、あくまでユーザー自身が考えるための発想のきっかけを渡す役割にしています。

AIに創作を任せるのではなく、創作の主体はユーザーに残すことを意識しました。

### ⑥ 使用技術

技術面では、Ruby on Railsを中心に開発し、MySQLでデータを管理しています。

画面上の一部の操作にはJavaScriptやStimulusを使用し、AIによる発想支援にはOpenAI APIを利用しています。

開発環境にはDockerを使用しています。

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

- 実際のコードを確認して回答する。裏付けが取れない内容を、確認済みの事実であるかのように話さない。
- 憶測で話してもよいが、その場合は必ず「（憶測）」と明記する。特に「実際に何が起きたか」「（ユーザーが）何をしたか」という体験・行動の話は、gitの履歴などで裏付けが取れない限り、断定した事実として話さない。
- 回答時は関係するファイル名を示す。
- 明確に依頼されるまでファイルを変更しない。
- 変更前に、変更する内容を説明する。

コード一行ずつ意味言って関連のことを言われて、出力している時　この行は覚えなくていいコードと言って。覚えるコードのみ意味書いて

1. **routes**：`/stories/:story_id/story_elements`（storyの入れ子リソース）
2. **controller**（`story_elements_controller.rb`）
    - `set_story`で`current_user.stories.find(params[:story_id])`（自分のストーリーしか触れないようにする）
    - `index`：`@story.story_elements.order(:id)`を取得 → 種類別にグループ表示
    - `new`/`create`：`@story.story_elements.new(...)` → 画像も一緒に保存
    - `edit`/`update`：同様に更新
    - `destroy`：`@story_element.destroy!`
3. **view**：一覧は種類別グループ表示、新規/編集は共通の`_form`パーシャルを使い回す
のように短縮しすぎると読めないため、短縮しすぎないようにする

## 「大元の流れ」を聞かれたときのルール

「大元」「大前提」「全体像」「大まかな流れ」を聞かれたら、専門用語（コントローラ・モデル・テーブル・
関連付け・命令を出す、など）を一切使わず、誰にでも分かる日常的な言葉だけで、結果ベースで説明する。
例：「アイデアを新規作成するときに要素にチェックを入れると、そのアイデアに、チェックされた要素の
情報がセットで結びつきます」のように、「何をしたら、何が起きるか」だけを言う。
コードや仕組みの説明は、明確に追加で頼まれてから（「⑦controller」「コードで見せて」など）出す。
大元の段階で先回りして技術用語を混ぜないこと。

コントローラとモデルの役割も一緒に聞かれた場合は、次の2部構成にする。

1. 「# 大元の流れ」として、上記の日常語だけの説明
2. 「もう少し詳しく：コントローラとモデルは、それぞれ何をしているか」という別見出しで、
   **コントローラがしていること** / **モデルがしていること** を太字の小見出しにして、
   それぞれ1〜2文で書く。ここでもテーブル名・カラム名までは出さず、
   「実際の保存方法は、コントローラは知らない」「別の専用の場所に記録される」のように、
   役割同士の関係性が伝わる言い方にする。テーブル名やコードは、さらに追加で頼まれてから出す。

## 学習目的

このプロジェクトは、未経験・ジュニア向けRails自社開発企業の
技術面接・ポートフォリオ深掘り対策として学習する。

基本はプロジェクト全体を網羅的に学習せず、
対象機能の説明に必要なコードだけに絞る方法で学んでいきたい。
ただ、対象機能の説明に必要なコード理解する上で必要なコード、関連しているコードだと判断したものは表示して欲しい。


## コードの学習レベル

機能を調査するときは、関係するコードを次の3段階に分類する。

### A：深く理解する
対象機能の中心処理。
コードを見ながら、画面操作からDB保存・取得・表示までを
自分の言葉で説明できる状態を目標にする。

### B：役割だけ理解する
対象機能を支える一般的なRailsコード。
暗記せず、何のためにあるか分かればよい。

### C：学習しない
対象機能と直接関係しないコード、
CSS、細かいHTML、GemやRails本体の内部コード、
同じ内容を繰り返すCRUDコード。

判断に迷ったコードはAに広げず、原則Bにする。
対象機能の中心処理を説明するために必要な場合だけAにする。

Aだけ詳しく説明する。
Bは短く説明する。
Cは説明しない。

## 機能学習コードのランク表示ルール

出てきたファイルごとに、必ず次のランクを付けること。

### A：深く理解する
対象機能の中心コード。
コードを見ながら、処理の流れ・使うModel・DBの変化・最終表示まで説明できる必要がある。

### B：役割だけ理解する
対象機能を支える一般的なコード。
何のためにあるかを1〜2文で説明できればよく、暗記や細かい実装理解は不要。

### C：今は学習しない
対象機能の面接説明に直接必要ないコード。
細かいHTML、CSS、Gem内部、Rails内部、汎用的な補助処理など。

⑥ routes
⑦ controller
⑧ model・関連付け
⑨ DBテーブル・カラム
⑩ view
⑪ JavaScript・Gem・外部API

について、それぞれ必ず以下を示すこと。

- ランク
- ファイル名
- メソッド名・関連付け名・該当箇所
- どこまで理解すれば完了か

出力例：

- A：`app/controllers/stories_controller.rb`
  - `move_up`
  - `move_down`
  - `swap_positions`
  - 完了条件：コードを見ながら、隣のストーリー取得とposition入れ替えを説明できる

- B：`config/routes.rb`
  - `resources :stories`
  - `member do ... end`
  - 完了条件：通常CRUDと独自の並び替えURLをControllerへ渡す役割だと分かればよい

- C：`app/javascript/controllers/character_counter_controller.js`
  - 完了条件：今回は読まなくてよい

## コード説明時の追加ルール

- 滅多に使われない保険的なコード（`||`によるbuild-or-reuse、`build_◯◯ if ◯◯.nil?`のようなnilガード、
  「本来起きないはずのケース」への防御的な分岐など）が出てきたら、詳しく説明する前に必ず一旦立ち止まり、
  「これは深掘り不要な保険コードだが、それでも詳しく見るか」を確認してから進める。
  決まった言い回しを毎回使う必要はないが、立ち止まって確認するという行動は必須。
- コードを1行ずつ説明するときは、「保存する前」「ここで保存された」「まだメモリの中だけの状態」のような、
  今がどのタイミング・状態なのかを示すコメントを必ず付ける。状況が分かることで意味が理解しやすくなる。
- view（画面表示側）のコードを1行ずつ説明するときは、「どのボタンを押した後に表示されるか」
  「まだ何も操作していない状態で表示されるものか」のような、画面上のどんな操作・状況に対応するコードなのかを
  必ず1行ずつ伝える。それが無いと、今何をしている場面のコードなのかが分からなくなる。
- テーブル名・関連付け名・変数名などの専門用語を使うときは、それが具体的に何を指しているのか
  （実物なのか、実物同士をつなぐ記録なのか、何と紛らわしくて何ではないのか）を、
  使う前に必ず説明する。
- メソッド名・アクション名・変数名（`consistency`、`@elements`、`@selected_element`など）を出したら、
  「これはURLを作っているだけ」のようなコードの仕組みの説明だけで終わらせず、
  その名前自体が何を意味するか（例：「consistencyは"整合性"という意味で、整合性チェック機能そのものを指す」
  「@elementsはプルダウンに並べる要素の候補一覧という意味」）も必ず一緒に説明する。
- 機能全体を⑥routes〜⑪JavaScript・Gem・外部APIでまとめて出すときは、次の形式を守る。
  - Gemを使うかを先に一言で書く
  - ④画面操作は、番号付きの箇条書きで具体的なユーザー操作の流れを書く
  - 同じファイルのコードは1つのコードブロックにまとめ、説明はコード内のコメント（`#`や`<%# %>`）として
    各行のすぐ下に書く。コードとコードの間に地の文を挟んで何度も分割しない
  - 呼び出し部分（例：`StoryElement.sorted_by_kind_and_name(...)`）には、
    「↑ ここで◯◯モデルの◯◯メソッドを呼んでいる」のように、呼んでいる場所だと明記する
  - 複数行にわたる処理は「結論：◯◯が入る／◯◯になる」のように、先に結論を書いてから
    仕組みの説明を続ける
  - viewのコードには「まだ何も操作していない状態」「ボタンを押した後」のような
    画面操作の状況を必ず添える
  - 1行ずつの意味を書いただけで終わらせない。コードのまとまり（メソッド1つ分など）の最後に、
    「結果として、画面には◯◯が表示される」「結果として、DBの◯◯が変わる」のように、
    そのまとまり全体が最終的に何を実現したのかを、太字などで強調して必ず書く

## 技術質問への回答テンプレート（6パターン）

技術質問（面接想定・深掘り想定）をされたら、まず質問の種類を下の6パターンから判定し、
該当するテンプレートの型どおりに埋めて回答する。事実確認できていない部分は「（憶測）」と明記する。
コードから裏付けが取れる場合は、ファイル名・メソッド名を添える。

### ① 定義型
**使う場面**：「〇〇とは何ですか？」

**判断基準（②か②'かを選ぶ）**：これは、1回のリクエストの中で、順番に動くものか？
- はい（フォームオブジェクト、サービスオブジェクト、ActiveJobなど）→ ②実際の流れ
- いいえ（Gemfile、MVC、SSL、credentialsなど）→ ②'具体的に何をするか

```
①全体の答えまとめ：
  〇〇な場合（具体的な状況・条件）に、
  △△という問題（本来Controllerに書くと長くなる／Modelだけでは扱いにくい、など）を、
  □□するための専用の◇◇（クラス・仕組みなど）です。

②実際の流れ（前後関係・分岐があるものだけ）：
  1. 〇〇する前（準備のタイミング）：何をするか
  2. 〇〇されたあと（受け取るタイミング）：何をするか
  3. 〇〇の場合／△△の場合（分岐するタイミング）：それぞれどうなるか

②'具体的に何をするか（流れがないものはこちら）：
  ・〇〇という中身がある
  ・〇〇ができる
  ・結果、〇〇になる（このクラス／仕組みがあることで、最終的にどうなるか）

③使う場所・担当ファイル：
  〇〇 → app/models/〇〇.rb など（場所が重要な質問だけ書く）

④創記録での実際の使用状況：
  使っている／使っていないを、根拠ファイルとともに正直に書く
```

**面接で話す文**：〇〇は、【①全体の答えまとめ】です。【②実際の流れ、または②'具体的に何をするかを1〜2文でつなげたもの】。（④が「使っている」場合はそのまま続ける／「使っていない」場合は別枠で正直に補足する）

### ② 構成・仕組み型
**使う場面**：「〇〇はどのような仕組みですか？」「〇〇をどのように実装しましたか？」「〇〇の構成を説明してください」

**話す順番**：全体 → 主な構成 → 使うメソッド → 流れ → 創記録では

```
全体：〇〇 → 何をする仕組みか
主な構成（その質問に関係するものだけ）：
  Gem → 〇〇：役割／担当ファイル → Gemfile
  Model → 〇〇：役割／担当ファイル → app/models/〇〇.rb
  Controller → 〇〇：役割／担当ファイル → app/controllers/〇〇_controller.rb
  View → 〇〇：役割／担当ファイル → app/views/〇〇/〇〇.html.erb
  DB → 〇〇：役割／担当ファイル → db/migrate/〇〇.rb ・ schema.rb
  外部サービス → 〇〇：役割／担当ファイル → config/〇〇 など
使うメソッド：〇〇メソッド → 何をする
流れ：〇〇 → 〇〇 → 〇〇 → 結果
自分のアプリでは：どの機能で → 何のために使っている
```

**面接で話す文**：〇〇は、【何をする仕組みか】です。主に【Gem / Model / Controller など】で構成しています。処理は【〇〇 → 〇〇 → 〇〇】という流れです。創記録では【どの機能で何のために使っているか】です。

### ③ 問題・対策型
**使う場面**：「〇〇とはどんな問題ですか？」「どう対策しますか？」「エラーやパフォーマンス問題にどう対応しましたか？」

**話す順番**：問題 → 原因 → 対策 → 結果

```
問題：〇〇が起きる
原因：〇〇が原因
対策：〇〇を使う／〇〇を修正
結果：〇〇を防ぐ／改善する
（必要なら）Model → ファイル名／Controller → ファイル名／〇〇メソッド → 役割
```

**面接で話す文**：〇〇という問題です。原因は【〇〇】です。そのため【〇〇】で対策し、【〇〇】を防ぎます。自分のサービスでは、【実際に行った対策】で対応しました。（自分のサービスで実際に対応した場合のみ）

### ④ 選定理由型
**使う場面**：「なぜ〇〇を使ったんですか？」「〇〇を選んだ理由は何ですか？」

**話す順番**：結論 → 理由 → メリット → 創記録では

```
結論：〇〇を採用
理由：〇〇だから
メリット：〇〇できる
創記録では：〇〇のために使用
```

**面接で話す文**：〇〇を採用しました。理由は【〇〇】だからです。【〇〇】というメリットがあり、創記録では【何のために使っているか】で利用しています。

### ⑤ 比較型
**使う場面**：「〇〇と△△の違いは何ですか？」「どう使い分けますか？」

**話す順番**：Aは何 → Bは何 → 一番の違い → 使い分け

```
A：〇〇 → 役割
B：△△ → 役割
一番の違い：〇〇
使い分け：〇〇のときはA／△△のときはB
```

**面接で話す文**：Aは【〇〇するもの】で、Bは【△△するもの】です。一番の違いは【〇〇】です。そのため、【〇〇の場合はA、△△の場合はB】と使い分けます。

### ⑥ 経験・行動型
**使う場面**：「エラーをどう解決しましたか？」「コードレビューをどう活かしましたか？」

**話す順番**：状況 → 行動 → 結果 → 学び

```
状況：〇〇という問題・課題
行動：〇〇を確認 → 〇〇を調査 → 〇〇を修正
結果：〇〇できるようになった
学び：〇〇が大切だと学んだ
```

**面接で話す文**：【〇〇という状況・問題】がありました。そこで【どのように調査・対応したか】を行いました。その結果、【どう改善・解決したか】につながりました。この経験から【何を学んだか】を学びました。