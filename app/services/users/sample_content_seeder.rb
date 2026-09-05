# frozen_string_literal: true

module Users
  # ✅ 新規登録・ゲスト開始の直後に、ストーリー・要素・イベント・詳細メモ・アイデアという
  #    主要機能を一通り体験できる見本データを1ユーザー分作る。
  #    実在する漫画・小説などとは無関係の、完全オリジナルの物語を使っている。
  #    ストーリー自体はis_sample: trueを付け、ゲストの「作れるストーリー1件まで」の
  #    上限には数えないようにしてある（User#guest_story_limit_reached?側で除外）。
  # rubocop:disable Metrics/ClassLength
  class SampleContentSeeder
    # ✅ 要素（kind・名前・メモ）の一覧。build_elementsで、この定義から
    #    story.story_elementsを1件ずつ作り、keyで引けるHashにする。
    ELEMENT_DEFINITIONS = {
      mina: { kind: :character, name: "ミナ",
              memo: "灯台守見習い。好奇心旺盛で、周りをよく観察している。" },
      wolf: { kind: :character, name: "ウルフ老人",
              memo: "元漁師。地図の噂を知っているが、口が重い。" },
      compass: { kind: :item, name: "潮読みの羅針盤",
                 memo: "潮の流れを読める、灯台に隠されていた古い羅針盤。" },
      lighthouse: { kind: :place, name: "灯台",
                    memo: "ミナが働く古い灯台。物語はここから始まる。" },
      cove: { kind: :place, name: "北の入り江",
              memo: "地図に記された、人が近づかない入り江。" },
      guild: { kind: :organization, name: "灯台守組合",
               memo: "灯台守たちの組合。過去に地図を巡る対立があった。" }
    }.freeze

    # ✅ イベント（=章）の一覧。build_eventsで、タイトルの先頭に並び順どおり
    #    「1章」「2章」…と付けながら、この定義からstory.story_eventsを作る。
    EVENT_DEFINITIONS = [
      { title: "地図が消えた朝", body: "灯台の記録庫から、古い地図が忽然と姿を消していた。" },
      { title: "ウルフ老人への相談", body: "ミナは幼い頃から世話になっているウルフ老人を訪ね、地図について尋ねる。" },
      { title: "羅針盤の発見", body: "灯台の壁の隙間から、潮読みの羅針盤を見つける。" },
      { title: "組合の記録を調べる", body: "灯台守組合の古い記録から、過去に地図を巡る争いがあったことを知る。" },
      { title: "北の入り江への旅", body: "羅針盤が示す先、誰も近づかない北の入り江へ、ウルフ老人と共に向かう。" }
    ].freeze

    # ✅ 各イベント（EVENT_DEFINITIONSと同じ並び順）に登場させる要素のkey一覧。
    #    同じ要素をわざと複数イベントにまたがって登場させ、整合性チェックで
    #    「この要素が出ているイベントだけ絞り込む」機能を試せるようにしている。
    EVENT_ELEMENT_KEYS = [
      %i[mina lighthouse],
      %i[mina wolf],
      %i[mina compass lighthouse],
      %i[mina guild],
      %i[mina wolf compass cove]
    ].freeze

    # ✅ 詳細メモ（=話）の一覧。event_index はEVENT_DEFINITIONS（章の並び順）の
    #    何番目にぶら下げるか。この並び順どおりに、章をまたいでも1に戻らない
    #    通し番号「1話」「2話」…をタイトルの先頭に付ける。
    DETAIL_MEMO_DEFINITIONS = [
      # -- 1章 地図が消えた朝 --
      { event_index: 0, title: "記録庫の鍵は開いていた",
        memo: "誰かが鍵を開けて中に入った形跡がある。", element_keys: %i[lighthouse] },
      { event_index: 0, title: "誰も気づかなかった夜",
        memo: "記録庫は普段誰も出入りしないため、いつ地図が消えたのか分からない。", element_keys: %i[lighthouse] },
      { event_index: 0, title: "最初に気づいたのはミナ",
        memo: "点検のため記録庫を開けたミナが、真っ先に異変に気づいた。", element_keys: %i[mina] },
      # -- 2章 ウルフ老人への相談 --
      { event_index: 1, title: "老人の歯切れの悪さ",
        memo: "地図の話になると、ウルフ老人は言葉を濁した。", element_keys: %i[wolf] },
      { event_index: 1, title: "昔語りの途中で黙り込む老人",
        memo: "地図の話になると、ウルフ老人は昔語りの途中で急に黙り込んだ。", element_keys: %i[wolf] },
      { event_index: 1, title: "手がかりは羅針盤という言葉",
        memo: "老人は最後に、小さな声で「羅針盤を探せ」とだけ言った。", element_keys: %i[wolf compass] },
      # -- 3章 羅針盤の発見 --
      { event_index: 2, title: "羅針盤の刻印",
        memo: "羅針盤の裏に、灯台守組合の紋章のような刻印があった。", element_keys: %i[compass guild] },
      { event_index: 2, title: "壁の隙間に隠されていた理由",
        memo: "羅針盤はわざと壁の隙間に隠されていたようだった。", element_keys: %i[lighthouse compass] },
      { event_index: 2, title: "潮の匂いがする羅針盤",
        memo: "羅針盤には、潮の匂いが染みついていた。", element_keys: %i[compass] },
      # -- 4章 組合の記録を調べる --
      { event_index: 3, title: "争いの記録",
        memo: "50年前、地図の所有を巡って組合内で対立があったと記されていた。", element_keys: %i[guild] },
      { event_index: 3, title: "破られたページ",
        memo: "記録の一部が意図的に破り取られていた。", element_keys: [] },
      { event_index: 3, title: "記録庫の管理者だった人物",
        memo: "当時の記録庫の管理者の名前が、別の記録に残っていた。", element_keys: %i[guild] },
      # -- 5章 北の入り江への旅 --
      { event_index: 4, title: "潮の音が導く",
        memo: "羅針盤の針が北の入り江を指したまま止まった。", element_keys: %i[compass cove] },
      { event_index: 4, title: "入り江で見た影",
        memo: "入り江の奥に、何か人工物のような影が見えた。", element_keys: [] },
      { event_index: 4, title: "ウルフ老人の足取りが鈍る",
        memo: "入り江に近づくにつれ、ウルフ老人の足取りが鈍くなった。", element_keys: %i[wolf cove] }
    ].freeze

    # ✅ 「破られたページ」はDETAIL_MEMO_DEFINITIONSの11番目(0始まりで10)。
    #    後でアイデアの配置先として使うため、番号で覚えておく。
    TORN_PAGE_MEMO_INDEX = 10

    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      ActiveRecord::Base.transaction do
        build_story
        build_elements
        build_events
        link_events_and_elements
        build_detail_memos
        build_ideas
      end
    end

    private

    attr_reader :user, :story, :elements, :events, :torn_page_memo

    def build_story
      @story = user.stories.create!(
        title: "灯台守と消えた地図",
        description: "小さな港町の灯台守見習いが、記録庫から消えた古い地図を巡って手がかりを追う物語です。" \
                     "この一件は、創記録の使い方を確認するための見本として最初から入っています。",
        is_sample: true,
        position: 10
      )
    end

    def build_elements
      @elements = ELEMENT_DEFINITIONS.transform_values { |attrs| story.story_elements.create!(attrs) }
    end

    # ✅ タイトルの先頭に「1章」「2章」…と、時系列（並び順）どおりの章番号を付ける
    def build_events
      @events = EVENT_DEFINITIONS.each_with_index.map do |attrs, i|
        chapter_number = i + 1
        story.story_events.create!(
          title: "#{chapter_number}章 #{attrs[:title]}",
          body: attrs[:body],
          position: chapter_number * 10
        )
      end
    end

    def link_events_and_elements
      events.each_with_index do |event, i|
        event.story_elements = EVENT_ELEMENT_KEYS[i].map { |key| elements[key] }
      end
    end

    def build_detail_memos
      detail_memos = DETAIL_MEMO_DEFINITIONS.each_with_index.map do |attrs, i|
        create_detail_memo(events[attrs[:event_index]], episode_number: i + 1, attrs: attrs)
      end
      @torn_page_memo = detail_memos[TORN_PAGE_MEMO_INDEX]
    end

    def create_detail_memo(event, episode_number:, attrs:)
      detail_memo = event.story_event_ideas.create!(
        title: "#{episode_number}話 #{attrs[:title]}",
        memo: attrs[:memo],
        position: (event.story_event_ideas.maximum(:position) || 0) + 10
      )
      linked_elements = attrs[:element_keys].map { |key| elements[key] }
      detail_memo.story_elements = linked_elements if linked_elements.present?
      detail_memo
    end

    def build_ideas
      build_placed_ideas
      build_unplaced_ideas
    end

    # ✅ すでにストーリー内の何かに配置(紐付け)済みのアイデア。
    #    配置先の種類（ストーリー本体／イベント／要素／詳細メモ）を1つずつ変えて見本にする。
    def build_placed_ideas
      place_idea(
        title: "地図を隠したのは誰か",
        memo: "犯人候補を整理しておくアイデアメモ。組合の誰かが関係しているかもしれない。",
        placeable: story
      )
      place_idea(
        title: "羅針盤が壊れていたら",
        memo: "もし羅針盤が壊れていたら、別の手がかりで入り江の場所を探す展開も考えられる。",
        placeable: events[2] # 羅針盤の発見
      )
      place_idea(
        title: "ウルフ老人の過去",
        memo: "ウルフ老人自身が、若い頃に地図を巡る争いに関わっていた可能性。",
        placeable: elements[:wolf]
      )
      place_idea(
        title: "破られたページの中身",
        memo: "破り取られたページには、争いの当事者の名前が書かれていたかもしれない。",
        placeable: torn_page_memo
      )
    end

    def place_idea(title:, memo:, placeable:)
      idea = user.ideas.create!(title: title, memo: memo, is_sample: true)
      idea.create_idea_placement!(placeable: placeable, created_here: false, moved_at: Time.current)
      idea
    end

    # ✅ まだどこにも配置していないアイデア。/ideas（ホーム画面）にそのまま並ぶ。
    #    「灯台守と消えた地図」とは別の、単独のアイデアとして用意する。
    #    ちょっとした演出案ではなく、フック・謎・広げどころのある一つの
    #    物語の種として書き、「これはストーリーにできそうだ」と伝わる内容にする。
    def build_unplaced_ideas
      user.ideas.create!(
        title: "記憶を買い取る古書店の噂",
        memo: "町外れの古書店では、大切な記憶と引き換えに欲しい本を譲ってくれるという噂がある。" \
              "ある日、店主が姿を消し、代わりに残された一冊の本には、消えたはずの誰かの記憶が" \
              "書き込まれていた。古書店の正体や、主人公が引き換えに失った記憶の中身など広げどころが多く、" \
              "そのままストーリーにできそうな候補。",
        is_sample: true
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
