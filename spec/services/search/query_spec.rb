require "rails_helper"

RSpec.describe Search::Query, type: :service do
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
