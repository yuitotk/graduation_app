require "rails_helper"

RSpec.describe StoryEventIdeaElement, type: :model do
  let(:user) { create(:user) }
  let(:story) { create(:story, user: user) }
  let(:story_event) { create(:story_event, story: story) }
  let(:story_event_idea) { create(:story_event_idea, story_event: story_event) }
  let(:story_element) { create(:story_element, story: story) }

  it "story_event_idea と story_element の組み合わせがあれば有効" do
    link = build(:story_event_idea_element, story_event_idea: story_event_idea, story_element: story_element)
    expect(link).to be_valid
  end

  it "同じ組み合わせが既にあると無効" do
    create(:story_event_idea_element, story_event_idea: story_event_idea, story_element: story_element)
    link = build(:story_event_idea_element, story_event_idea: story_event_idea, story_element: story_element)
    expect(link).not_to be_valid
  end
end
