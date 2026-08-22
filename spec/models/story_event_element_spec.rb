require "rails_helper"

RSpec.describe StoryEventElement, type: :model do
  let(:user) { create(:user) }
  let(:story) { create(:story, user: user) }
  let(:story_event) { create(:story_event, story: story) }
  let(:story_element) { create(:story_element, story: story) }

  it "story_event と story_element の組み合わせがあれば有効" do
    link = build(:story_event_element, story_event: story_event, story_element: story_element)
    expect(link).to be_valid
  end

  it "同じ組み合わせが既にあると無効" do
    create(:story_event_element, story_event: story_event, story_element: story_element)
    link = build(:story_event_element, story_event: story_event, story_element: story_element)
    expect(link).not_to be_valid
  end
end
