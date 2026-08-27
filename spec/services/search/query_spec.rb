require "rails_helper"

RSpec.describe Search::Query, type: :service do
  let(:user) { create(:user) }

  # rubocop:disable Naming/MethodParameterName
  def call(q:, scope: "all", story_id: nil, story_element_ids: [])
    described_class.new(
      q: q,
      scope: scope,
      story_id: story_id,
      story_element_ids: story_element_ids,
      user: user
    ).call
  end
  # rubocop:enable Naming/MethodParameterName

  describe "ホーム未所属アイデアの検索" do
    it "タイトルの部分一致で見つかる" do
      idea = create(:idea, user: user, title: "うさぎのアイデア", memo: "m")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home][:created_here]).to include(idea)
    end

    it "メモの部分一致でも見つかる（今まで通り）" do
      idea = create(:idea, user: user, title: "t", memo: "うさぎが登場する")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home][:created_here]).to include(idea)
    end

    it "一致しない単語では見つからない" do
      create(:idea, user: user, title: "うさぎのアイデア", memo: "m")

      result = call(q: "きりん", scope: "home")

      expect(result[:home][:created_here]).to be_empty
    end
  end

  describe "要素での絞り込み" do
    let(:story) { create(:story, user: user) }
    let(:element_a) { create(:story_element, story: story, kind: "character", name: "キャラA") }
    let(:element_b) { create(:story_element, story: story, kind: "character", name: "キャラB") }

    def idea_linked_to(*elements, created_here: true)
      idea = create(:idea, user: user, title: "対象アイデア", memo: "m")
      placement = create(:idea_placement, idea: idea, placeable: story, created_here: created_here)
      placement.story_element_ids = elements.map(&:id)
      idea
    end

    it "要素を1つ指定すると、従来通りその要素が紐づくアイデアが見つかる" do
      idea = idea_linked_to(element_a)

      result = call(q: "対象", scope: "story", story_element_ids: [element_a.id])

      expect(result[:story][:created_here]).to include(idea)
    end

    it "複数指定すると、選んだ要素が全部そろって紐づいているアイデアが見つかる" do
      idea_both = idea_linked_to(element_a, element_b)

      result = call(q: "対象", scope: "story", story_element_ids: [element_a.id, element_b.id])

      expect(result[:story][:created_here]).to include(idea_both)
    end

    it "複数指定すると、一部の要素しか紐づいていないアイデアは見つからない" do
      idea_only_a = idea_linked_to(element_a)

      result = call(q: "対象", scope: "story", story_element_ids: [element_a.id, element_b.id])

      expect(result[:story][:created_here]).not_to include(idea_only_a)
    end

    it "選んだ要素が全部そろって紐づいているアイデアが無ければ見つからない" do
      idea_linked_to(element_a)

      result = call(q: "対象", scope: "story", story_element_ids: [element_a.id, element_b.id])

      expect(result[:story][:created_here]).to be_empty
    end

    # 移動してきたアイデア(moved)は、created_hereとは別テーブルの列(moved_at)で
    # 並び替えている。要素の複数指定と組み合わせたときにエラーにならないことを確認する
    # (本番のPostgreSQLでGROUP BY関連のエラーが実際に発生したための回帰テスト)
    it "移動してきたアイデアも、複数の要素で絞り込める" do
      idea_moved = idea_linked_to(element_a, element_b, created_here: false)

      result = call(q: "対象", scope: "story", story_element_ids: [element_a.id, element_b.id])

      expect(result[:story][:moved]).to include(idea_moved)
    end
  end

  describe "ひらがな/カタカナの表記ゆれ" do
    it "ひらがなで検索して、カタカナ表記のタイトルも見つかる" do
      idea = create(:idea, user: user, title: "ウサギのアイデア", memo: "m")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home][:created_here]).to include(idea)
    end

    it "カタカナで検索して、ひらがな表記のタイトルも見つかる" do
      idea = create(:idea, user: user, title: "うさぎのアイデア", memo: "m")

      result = call(q: "ウサギ", scope: "home")

      expect(result[:home][:created_here]).to include(idea)
    end
  end
end
