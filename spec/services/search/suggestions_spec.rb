require "rails_helper"

RSpec.describe Search::Suggestions, type: :service do
  let(:user) { create(:user) }

  # rubocop:disable Naming/MethodParameterName
  def call(q:, scope: "all", story_id: nil, story_element_id: nil)
    described_class.new(
      q: q,
      scope: scope,
      story_id: story_id,
      story_element_id: story_element_id,
      user: user
    ).call
  end
  # rubocop:enable Naming/MethodParameterName

  describe "ホーム未所属アイデアのサジェスト" do
    it "タイトルの部分一致で候補に出て、matched_by_memoはfalseになる" do
      create(:idea, user: user, title: "うさぎのアイデア", memo: "m")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home]).to include(title: "うさぎのアイデア", matched_by_memo: false)
    end

    it "メモの部分一致でも、そのアイデアのタイトルが候補に出て、matched_by_memoはtrueになる" do
      create(:idea, user: user, title: "森の物語", memo: "うさぎが登場する")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home]).to include(title: "森の物語", matched_by_memo: true)
    end

    it "タイトル・メモ両方に一致する場合は、matched_by_memoはfalseになる（タイトルからも分かるため）" do
      create(:idea, user: user, title: "うさぎの物語", memo: "うさぎが登場する")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home]).to include(title: "うさぎの物語", matched_by_memo: false)
    end
  end

  describe "ひらがな/カタカナの表記ゆれ" do
    it "ひらがなで検索して、カタカナ表記のタイトルも候補に出る" do
      create(:idea, user: user, title: "ウサギのアイデア", memo: "m")

      result = call(q: "うさぎ", scope: "home")

      expect(result[:home]).to include(title: "ウサギのアイデア", matched_by_memo: false)
    end
  end
end
