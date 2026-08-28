# spec/requests/quick_action_button_spec.rb
# rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
require "rails_helper"

RSpec.describe "QuickActionButton（右下の稲妻ボタン）", type: :request do
  let!(:user) do
    u = User.new(email: "quick-action-test@example.com")
    u.password = "password"
    u.save!
    u
  end

  before do
    post login_path, params: { email: user.email, password: "password" }
  end

  def menu_labels
    response.body.scan(%r{data-quick-action-menu-target="menu".*?</div>}m).first.to_s
  end

  describe "GET /ideas（ホーム）" do
    it "アイデア作成・AI作成の2つだけが表示される" do
      get ideas_path

      expect(response.body).to include('data-controller="quick-action-menu"')
      expect(menu_labels).to include("アイデア作成")
      expect(menu_labels).to include("AI作成")
      expect(menu_labels).not_to include("整合性チェック")
    end
  end

  describe "GET /stories/:id（ストーリー詳細）" do
    let!(:story) { user.stories.create!(title: "t", description: "d") }

    it "アイデア作成・AI作成・要素管理・整合性チェック・イベント追加の5つが表示される" do
      get story_path(story)

      labels = menu_labels
      %w[アイデア作成 AI作成 要素管理 整合性チェック イベント追加].each do |label|
        expect(labels).to include(label)
      end
    end
  end

  describe "GET /stories/:id/story_events/:id（イベント詳細）" do
    let!(:story) { user.stories.create!(title: "t", description: "d") }
    let!(:story_event) { story.story_events.create!(title: "e", body: "b", position: 1) }

    it "アイデア作成・AI作成・要素管理・整合性チェック・詳細メモ追加の5つが表示される" do
      get story_story_event_path(story, story_event)

      labels = menu_labels
      %w[アイデア作成 AI作成 要素管理 整合性チェック 詳細メモ追加].each do |label|
        expect(labels).to include(label)
      end
      expect(labels).not_to include("イベント追加")
    end
  end

  describe "GET /stories/:id/story_events/:id/story_event_ideas/:id（詳細メモ詳細）" do
    let!(:story) { user.stories.create!(title: "t", description: "d") }
    let!(:story_event) { story.story_events.create!(title: "e", body: "b", position: 1) }
    let!(:story_event_idea) { story_event.story_event_ideas.create!(title: "m", memo: "m", position: 1) }

    it "アイデア作成・AI作成・要素管理・整合性チェックの4つが表示され、追加系は出ない" do
      get story_story_event_story_event_idea_path(story, story_event, story_event_idea)

      labels = menu_labels
      %w[アイデア作成 AI作成 要素管理 整合性チェック].each do |label|
        expect(labels).to include(label)
      end
      expect(labels).not_to include("イベント追加")
      expect(labels).not_to include("詳細メモ追加")
    end
  end

  describe "GET /stories/:id/story_elements/:id（要素詳細）" do
    let!(:story) { user.stories.create!(title: "t", description: "d") }
    let!(:story_element) { story.story_elements.create!(kind: "character", name: "el") }

    it "アイデア作成・AI作成の2つだけが表示される" do
      get story_story_element_path(story, story_element)

      labels = menu_labels
      expect(labels).to include("アイデア作成")
      expect(labels).to include("AI作成")
      expect(labels).not_to include("整合性チェック")
    end
  end

  describe "対象外のページ" do
    it "ストーリー一覧では、ボタン自体が表示されない" do
      get stories_path

      expect(response.body).not_to include('data-controller="quick-action-menu"')
    end

    it "要素一覧では、ボタン自体が表示されない" do
      story = user.stories.create!(title: "t", description: "d")

      get story_story_elements_path(story)

      expect(response.body).not_to include('data-controller="quick-action-menu"')
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
