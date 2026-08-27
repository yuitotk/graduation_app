# rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
# spec/requests/searches_spec.rb
require "rails_helper"

RSpec.describe "Searches", type: :request do
  describe "GET /search" do
    let!(:user) { create(:user) }

    # ✅ まずここだけ、あなたのプロジェクトのログイン方法に合わせる
    before do
      # --- パターンA: SorceryのIntegrationヘルパが使える場合 ---
      # （rails_helper等で include Sorcery::TestHelpers::Rails::Integration が有効になってる想定）
      if respond_to?(:login_user)
        login_user(user)
      elsif respond_to?(:auto_login)
        auto_login(user)

      # --- パターンB: 自前でログインPOSTする場合（ルートが違うならここだけ直す） ---
      else
        # 例: SessionsController で create が /login ならこれ
        post login_path, params: { email: user.email, password: "password" }
      end
    end

    it "qが空なら結果を出さない（フォーム促しが出る）" do
      get search_path, params: { q: "" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("検索ワードを入力して検索してください")
    end

    it "scope=all ならカテゴリ件数が表示される" do
      # ここでデータを作らなくても、表示文言が出ることだけを最小確認（壊れ検知用）
      get search_path, params: { q: "a", scope: "all" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ホーム未所属")
      expect(response.body).to include("ストーリー内")
      expect(response.body).to include("イベント内")
      expect(response.body).to include("要素内")
    end

    it "scope=story なら『ストーリー内』の1カテゴリ表示になる（最低限の文言チェック）" do
      get search_path, params: { q: "a", scope: "story" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ストーリー内")
    end

    it "within_story=1 で story_id を渡すと『この作品内（作品名）』が条件表示に出る" do
      story = create(:story, user: user, title: "ポケモン")

      get search_path, params: {
        q: "a",
        scope: "all",
        within_story: "1",
        story_id: story.id
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("この作品内（ポケモン）")
    end

    describe "要素での絞り込み（複数選択）" do
      let(:story) { create(:story, user: user, title: "検索絞り込み確認用") }
      let(:element_a) { create(:story_element, story: story, kind: "character", name: "アリス") }
      let(:element_b) { create(:story_element, story: story, kind: "character", name: "ボブ") }

      def idea_linked_to(story, user, *elements, created_here: true)
        idea = create(:idea, user: user, title: "対象アイデア", memo: "m")
        placement = create(:idea_placement, idea: idea, placeable: story, created_here: created_here)
        placement.story_element_ids = elements.map(&:id)
        idea
      end

      it "ヘッダーで選んだ要素1個がそのまま結果に反映される（後方互換）" do
        idea_linked_to(story, user, element_a)

        get search_path, params: {
          q: "対象", scope: "all", within_story: "1", story_id: story.id, story_element_id: element_a.id
        }

        expect(response.body).to include("対象アイデア")
      end

      it "結果ページで複数チェックすると、全部そろって紐づくアイデアだけに絞り込まれる" do
        idea_linked_to(story, user, element_a, element_b)

        get search_path, params: {
          q: "対象", scope: "all", within_story: "1", story_id: story.id,
          search_story_element_ids: [element_a.id, element_b.id]
        }

        expect(response.body).to include("対象アイデア")
      end

      it "一部の要素しか紐づいていないアイデアは、複数選ぶと表示されなくなる" do
        idea_linked_to(story, user, element_a)

        get search_path, params: {
          q: "対象", scope: "all", within_story: "1", story_id: story.id,
          search_story_element_ids: [element_a.id, element_b.id]
        }

        expect(response.body).not_to include("対象アイデア")
      end

      it "結果ページでチェックを全部外すと絞り込みが解除される" do
        idea_linked_to(story, user, element_a)

        get search_path, params: {
          q: "対象", scope: "all", within_story: "1", story_id: story.id,
          search_story_element_ids: [""]
        }

        expect(response.body).to include("対象アイデア")
      end

      # 移動してきたアイデアはidea_placements.moved_atで並び替えており、
      # 要素の複数指定と組み合わせた時に画面が壊れないことを確認する
      # （本番のPostgreSQLでGROUP BY関連のエラーが実際に発生したための回帰テスト）
      it "移動してきたアイデアも、複数の要素で絞り込んだ画面に正常に表示される" do
        idea_linked_to(story, user, element_a, element_b, created_here: false)

        get search_path, params: {
          q: "対象", scope: "all", within_story: "1", story_id: story.id,
          search_story_element_ids: [element_a.id, element_b.id]
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("対象アイデア")
      end
    end

    it "作品内ONではホーム未所属が結果に混ざらない（ストーリー内だけ出る）" do
      story = create(:story, user: user, title: "ポケモン")

      # ストーリー内アイデア（placementあり）
      in_story_idea = create(:idea, user: user, title: "ストーリーのアイデア", memo: "ピカ")
      create(:idea_placement,
             idea: in_story_idea,
             placeable: story,
             created_here: true)

      # ホーム未所属アイデア（placementなし）
      create(:idea, user: user, title: "ホームのアイデア", memo: "ピカ")

      get search_path, params: {
        q: "ピカ",
        scope: "all",
        within_story: "1",
        story_id: story.id
      }

      expect(response).to have_http_status(:ok)

      # ✅ ストーリー内は出る
      expect(response.body).to include("ストーリーのアイデア")

      # ✅ ホーム未所属は出ない
      expect(response.body).not_to include("ホームのアイデア")
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
