# rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
require "rails_helper"

# パンくずリスト生成ロジック（AiGenerationsController / RandomWordsController /
# IdeasControllerに重複していた処理）をconcernへ切り出すにあたり、
# 「切り出す前」と「切り出した後」で表示内容が変わっていないことを保証するための特性テスト。
RSpec.describe "Breadcrumbs", type: :request do
  let!(:user) { create(:user, password: "password") }

  before do
    post login_path, params: { email: user.email, password: "password" }
  end

  describe "GET /random_words/pick" do
    let!(:story) { create(:story, user: user, title: "ストーリーA") }
    let!(:story_event) { create(:story_event, story: story, title: "イベントA") }
    let!(:story_event_idea) { create(:story_event_idea, story_event: story_event, title: "詳細メモA") }
    let!(:story_element) { create(:story_element, story: story, name: "要素A") }

    before do
      RandomWord.create!(word: "テスト名詞#{SecureRandom.hex(4)}", part_of_speech: "noun")
      RandomWord.create!(word: "テスト動詞#{SecureRandom.hex(4)}", part_of_speech: "verb")
    end

    it "placeable_typeがStoryのとき、ストーリー名だけのパンくずになる" do
      get random_words_pick_path, params: { placeable_type: "Story", placeable_id: story.id }

      expect(response.body).to include("ストーリーA")
      expect(response.body).not_to include("イベントA")
    end

    it "placeable_typeがStoryEventのとき、ストーリー→イベントのパンくずになる" do
      get random_words_pick_path, params: { placeable_type: "StoryEvent", placeable_id: story_event.id }

      expect(response.body).to include("ストーリーA")
      expect(response.body).to include("イベントA")
    end

    it "placeable_typeがStoryEventIdeaのとき、ストーリー→イベント→詳細メモのパンくずになる" do
      get random_words_pick_path, params: { placeable_type: "StoryEventIdea", placeable_id: story_event_idea.id }

      expect(response.body).to include("ストーリーA")
      expect(response.body).to include("イベントA")
      expect(response.body).to include("詳細メモA")
    end

    it "placeable_typeがStoryElementかつreturn_toが無いとき、ストーリー→要素一覧→要素名のパンくずになる" do
      get random_words_pick_path, params: { placeable_type: "StoryElement", placeable_id: story_element.id }

      expect(response.body).to include("ストーリーA")
      expect(response.body).to include("要素一覧")
      expect(response.body).to include("要素A")
      expect(response.body).not_to include("イベントA")
    end

    it "placeable_typeがStoryElementかつreturn_toにfrom=story_eventが含まれるとき、イベント経由のパンくずになる" do
      return_to = "/stories/#{story.id}/story_events/#{story_event.id}?from=story_event&story_event_id=#{story_event.id}"

      get random_words_pick_path,
          params: { placeable_type: "StoryElement", placeable_id: story_element.id, return_to: return_to }

      expect(response.body).to include("ストーリーA")
      expect(response.body).to include("イベントA")
      expect(response.body).to include("要素一覧")
      expect(response.body).to include("要素A")
    end
  end

  describe "GET /ideas/new" do
    let!(:story) { create(:story, user: user, title: "アイデア用ストーリー") }

    it "placeable_typeがStoryのとき、ストーリー名のパンくずになる" do
      get new_idea_path, params: { placeable_type: "Story", placeable_id: story.id }

      expect(response.body).to include("アイデア用ストーリー")
    end
  end

  describe "GET /ideas/:id/edit" do
    let!(:story) { create(:story, user: user, title: "編集用ストーリー") }
    let!(:story_element) { create(:story_element, story: story, name: "編集用要素") }
    let!(:idea) { create(:idea, user: user, title: "対象アイデア") }

    before do
      create(:idea_placement, idea: idea, placeable: story_element, created_here: true)
    end

    it "配置先が要素のとき、ストーリー→要素一覧→要素名のパンくずになる" do
      get edit_idea_path(idea)

      expect(response.body).to include("編集用ストーリー")
      expect(response.body).to include("要素一覧")
      expect(response.body).to include("編集用要素")
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
