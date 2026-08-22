require "rails_helper"

RSpec.describe StoryEventIdea, type: :model do
  let(:story_event) { create(:story_event, story: create(:story, user: create(:user))) }

  it "story_event・title があれば有効" do
    idea = build(:story_event_idea, story_event: story_event)
    expect(idea).to be_valid
  end

  it "title が無いと無効" do
    idea = build(:story_event_idea, story_event: story_event, title: nil)
    expect(idea).not_to be_valid
  end

  it "story_event が無いと無効" do
    idea = build(:story_event_idea, story_event: nil)
    expect(idea).not_to be_valid
  end
end
