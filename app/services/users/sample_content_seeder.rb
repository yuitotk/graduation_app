# frozen_string_literal: true

module Users
  # ✅ 新規登録・ゲスト開始の直後に、ストーリー・要素・イベント・詳細メモ・アイデアという
  #    主要機能を一通り体験できる見本データを1ユーザー分作る。
  #    実在する漫画・小説などとは無関係の、完全オリジナルの物語を使っている。
  #    ストーリー自体はis_sample: trueを付け、ゲストの「作れるストーリー1件まで」の
  #    上限には数えないようにしてある（User#guest_story_limit_reached?側で除外）。
  # rubocop:disable Metrics/ClassLength
  class SampleContentSeeder
    # ✅ 要素（kind・名前・メモ・マーカー）の一覧。build_elementsで、この定義から
    #    story.story_elementsを1件ずつ作り、keyで引けるHashにする。
    #    marker（最大4文字の絵文字など）は、検索結果やAI作成の配置先選択などで
    #    名前の前に付く短い目印。マーカー機能も実際に使われた状態にしておく。
    ELEMENT_DEFINITIONS = {
      mina: { kind: :character, name: "ミナ", marker: "👧",
              memo: "灯台守見習い。好奇心旺盛で、周りをよく観察している。" },
      wolf: { kind: :character, name: "ウルフ老人", marker: "👴",
              memo: "元漁師。地図の噂を知っているが、口が重い。" },
      compass: { kind: :item, name: "潮読みの羅針盤", marker: "🧭",
                 memo: "潮の流れを読める、灯台に隠されていた古い羅針盤。" },
      lighthouse: { kind: :place, name: "灯台", marker: "🔦",
                    memo: "ミナが働く古い灯台。物語はここから始まる。" },
      cove: { kind: :place, name: "北の入り江", marker: "🌊",
              memo: "地図に記された、人が近づかない入り江。" },
      guild: { kind: :organization, name: "灯台守組合", marker: "⚓",
               memo: "灯台守たちの組合。過去に地図を巡る対立があった。" },
      sei: { kind: :character, name: "セイ", marker: "🗝️",
             memo: "北の入り江の隠れ家に一人で暮らす人物。灯台守組合とは因縁のある一族の末裔。" },
      hideout: { kind: :place, name: "入り江の隠れ家", marker: "🏚️",
                 memo: "入り江の奥、岩陰に隠すように建てられた小屋。長年、外部の目から隠されていた。" }
    }.freeze

    # ✅ イベント（=章）の一覧。build_eventsで、タイトルの先頭に並び順どおり
    #    「1章」「2章」…と付けながら、この定義からstory.story_eventsを作る。
    EVENT_DEFINITIONS = [
      { title: "地図が消えた朝", body: "灯台の記録庫から、古い地図が忽然と姿を消していた。" },
      { title: "ウルフ老人への相談", body: "ミナは幼い頃から世話になっているウルフ老人を訪ね、地図について尋ねる。" },
      { title: "羅針盤の発見", body: "灯台の壁の隙間から、潮読みの羅針盤を見つける。" },
      { title: "組合の記録を調べる", body: "灯台守組合の古い記録から、過去に地図を巡る争いがあったことを知る。" },
      { title: "北の入り江への旅", body: "羅針盤が示す先、誰も近づかない北の入り江へ、ウルフ老人と共に向かう。" },
      { title: "入り江の隠れ家", body: "入り江の奥、岩陰に隠すように建てられた小さな小屋を見つける。" },
      { title: "小屋の住人セイ", body: "小屋には、長年そこで一人暮らしているという人物、セイが住んでいた。" },
      { title: "地図を持ち出した理由", body: "セイは、消えた地図を自分が持ち出したことを認め、その理由を静かに語り始める。" },
      { title: "50年前の対立の真相",
        body: "セイの祖先と灯台守組合との間にあった対立が、地図を巡る因縁の始まりだったことが明らかになる。" },
      { title: "これからの約束", body: "地図の扱いをどうするか、ミナたちはセイやウルフ老人と話し合い、新しい約束を交わす。" }
    ].freeze

    # ✅ 各イベント（EVENT_DEFINITIONSと同じ並び順）に登場させる要素のkey一覧。
    #    同じ要素をわざと複数イベントにまたがって登場させ、整合性チェックで
    #    「この要素が出ているイベントだけ絞り込む」機能を試せるようにしている。
    EVENT_ELEMENT_KEYS = [
      %i[mina lighthouse],
      %i[mina wolf],
      %i[mina compass lighthouse],
      %i[mina guild],
      %i[mina wolf compass cove],
      %i[mina wolf cove hideout],
      %i[mina wolf sei hideout],
      %i[mina sei],
      %i[mina wolf sei guild],
      %i[mina wolf sei guild]
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
        memo: "入り江に近づくにつれ、ウルフ老人の足取りが鈍くなった。", element_keys: %i[wolf cove] },
      # -- 6章 入り江の隠れ家 --
      { event_index: 5, title: "小屋を覆う蔦",
        memo: "小屋は蔦に覆われ、外からはほとんど見えないようになっていた。", element_keys: %i[hideout] },
      { event_index: 5, title: "焚き火の跡",
        memo: "小屋の前には、最近使われたばかりのような焚き火の跡があった。", element_keys: [] },
      { event_index: 5, title: "警戒するウルフ老人",
        memo: "ウルフ老人は、この小屋の存在を知っていたような素振りを見せた。", element_keys: %i[wolf] },
      # -- 7章 小屋の住人セイ --
      { event_index: 6, title: "セイの第一声",
        memo: "セイは驚いた様子もなく、「来ると思っていた」とだけ言った。", element_keys: %i[sei] },
      { event_index: 6, title: "机の上の古い写真",
        memo: "小屋の机には、若い頃のウルフ老人らしき人物が写った古い写真があった。", element_keys: %i[sei wolf] },
      { event_index: 6, title: "セイの静かな目",
        memo: "セイの目は、長い年月をひとりで過ごしてきた者特有の静けさをたたえていた。", element_keys: %i[sei] },
      # -- 8章 地図を持ち出した理由 --
      { event_index: 7, title: "地図を持ち出した夜",
        memo: "セイは、地図が消えた夜、自分がひとりで灯台に忍び込んだことを話した。", element_keys: %i[sei] },
      { event_index: 7, title: "理由はまだ話さない",
        memo: "なぜ地図が必要だったのかは、まだはっきりと語ろうとしない。", element_keys: %i[sei] },
      { event_index: 7, title: "ミナの問いかけ",
        memo: "ミナは、責めるでもなく、ただ静かに理由を尋ねた。", element_keys: %i[mina sei] },
      # -- 9章 50年前の対立の真相 --
      { event_index: 8, title: "セイの祖先の名前",
        memo: "セイの祖先の名は、組合の記録に記された「争いの当事者」の一人と一致していた。",
        element_keys: %i[sei guild] },
      { event_index: 8, title: "奪われた側だった過去",
        memo: "セイの一族は、50年前、組合によって地図の管理者の座を追われた側だったと分かる。",
        element_keys: %i[sei guild] },
      { event_index: 8, title: "ウルフ老人がずっと黙っていた理由",
        memo: "ウルフ老人自身も、当時その場に居合わせた一人だったことを、ようやく認める。",
        element_keys: %i[wolf sei] },
      # -- 10章 これからの約束 --
      { event_index: 9, title: "セイの願い",
        memo: "セイは、地図を独り占めしたいわけではなく、一族の名誉を回復したいだけだったと語る。",
        element_keys: %i[sei] },
      { event_index: 9, title: "組合との新しい関係",
        memo: "灯台守組合とセイの一族との関係を、これからどう築き直すかを話し合う。", element_keys: %i[sei guild] },
      { event_index: 9, title: "灯台へ戻る道",
        memo: "話し合いを終え、ミナたちは地図を手に、灯台への帰り道を歩き始める。", element_keys: %i[mina wolf] }
    ].freeze

    # ✅ 「破られたページ」はDETAIL_MEMO_DEFINITIONSの11番目(0始まりで10)。
    #    後でアイデアの配置先として使うため、番号で覚えておく。
    TORN_PAGE_MEMO_INDEX = 10

    # ✅ まだどこにも配置していない、ホームに並ぶ見本アイデアの一覧。
    #    「灯台守と消えた地図」とは無関係の、単独のアイデアとして用意する。
    #    情報を入れすぎて完成させてしまうと、そこから先を考える余地がなくなるため、
    #    ちょっとした引っかかり(小さな具体的な描写)は1つだけ足しつつ、
    #    「誰が」「なぜ」は空白のまま残し、広げやすいバランスにしている。
    #    ジャンルを散らし、ジャンルを問わずアイデア機能を体験できるようにする。
    UNPLACED_IDEA_DEFINITIONS = [
      { title: "記憶を買い取る古書店の噂", # ミステリー寄りファンタジー
        memo: "町外れの古書店では、大切な記憶と引き換えに欲しい本を譲ってくれるという噂がある。" \
              "ある日、店主が姿を消し、代わりに残された一冊の本には、消えたはずの誰かの記憶が" \
              "書き込まれていた。古書店の正体や、主人公が引き換えに失った記憶の中身など広げどころが多く、" \
              "そのままストーリーにできそうな候補。" },
      { title: "下駄箱に入っていた知らない写真", # 日常・学園ミステリー
        memo: "自分の下駄箱に、見覚えのない写真が1枚だけ入っていた。写っているのは、夜の校舎の屋上らしき" \
              "景色だけ。差出人も理由も分からない。誰が、何のために入れたのかを考えるところから、" \
              "キャラクターや出来事を広げていきやすいアイデア。" },
      { title: "時計の針が全部逆に動いていた朝", # SF
        memo: "ある朝目を覚ますと、家中の時計の針がすべて逆向きに動いていた。外に出ると、近所の犬まで" \
              "後ろ向きに歩いている。なぜ自分だけこれに気づいたのか、この先何が起こるのかを考えるところから" \
              "広げやすいアイデア。" },
      { title: "毎朝同じベンチに座る人", # 恋愛・青春
        memo: "通学路の公園のベンチに、毎朝同じ時間、同じ人が座っている。いつも同じ文庫本を読んでいるが、" \
              "話したことは一度もない。声をかけるきっかけや、その人の正体を考えるところから、恋愛ものに" \
              "広げやすいアイデア。" },
      { title: "廃部寸前の部活に来た転校生", # スポーツ・青春
        memo: "部員が足りず廃部寸前だった部活に、経験者らしい転校生が入ってきた。初対面のはずなのに、" \
              "なぜか最初からこちらの名前を知っていた。なぜこの部活を選んだのか、これからどう変わって" \
              "いくのかを考えるところから広げやすいアイデア。" },
      { title: "隣の空き部屋から聞こえる物音", # ホラー
        memo: "隣の部屋は空き部屋のはずなのに、毎晩同じ時刻になると物音が聞こえる。管理人に聞いても" \
              "要領を得ない。何が起きているのかを考えるところから広げやすいアイデア。" }
    ].freeze

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
    #    配置先の種類（ストーリー本体／イベント／要素／詳細メモ）を1つずつ変えて見本にし、
    #    それぞれ内容に合った要素も紐付けて、「アイデアと要素を結びつける」機能も
    #    実際に使われた状態にしておく。
    def build_placed_ideas
      place_idea(
        title: "地図を隠したのは誰か",
        memo: "犯人候補を整理しておくアイデアメモ。組合の誰かが関係しているかもしれない。",
        placeable: story, element_keys: %i[guild]
      )
      place_idea(
        title: "羅針盤が壊れていたら",
        memo: "もし羅針盤が壊れていたら、別の手がかりで入り江の場所を探す展開も考えられる。",
        placeable: events[2], element_keys: %i[compass] # 羅針盤の発見
      )
      place_idea(
        title: "ウルフ老人の過去",
        memo: "ウルフ老人自身が、若い頃に地図を巡る争いに関わっていた可能性。",
        placeable: elements[:wolf], element_keys: %i[wolf sei]
      )
      place_idea(
        title: "破られたページの中身",
        memo: "破り取られたページには、争いの当事者の名前が書かれていたかもしれない。",
        placeable: torn_page_memo, element_keys: %i[guild sei]
      )
    end

    def place_idea(title:, memo:, placeable:, element_keys: [])
      idea = user.ideas.create!(title: title, memo: memo, is_sample: true)
      placement = idea.create_idea_placement!(placeable: placeable, created_here: false, moved_at: Time.current)
      placement.story_elements = element_keys.map { |key| elements[key] }
      idea
    end

    # ✅ まだどこにも配置していないアイデア。/ideas（ホーム画面）にそのまま並ぶ。
    #    UNPLACED_IDEA_DEFINITIONSの各ジャンルを、そのままアイデアとして作る。
    def build_unplaced_ideas
      UNPLACED_IDEA_DEFINITIONS.each do |attrs|
        user.ideas.create!(title: attrs[:title], memo: attrs[:memo], is_sample: true)
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
