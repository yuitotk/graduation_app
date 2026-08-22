require "rails_helper"

RSpec.describe StoryEvent, type: :model do
  let(:story) { create(:story, user: create(:user)) }

  it "story・title・position があれば有効" do
    event = build(:story_event, story: story)
    expect(event).to be_valid
  end

  it "title が無いと無効" do
    event = build(:story_event, story: story, title: nil)
    expect(event).not_to be_valid
  end

  it "position が無いと無効" do
    event = build(:story_event, story: story, position: nil)
    expect(event).not_to be_valid
  end

  it "story が無いと無効" do
    event = build(:story_event, story: nil)
    expect(event).not_to be_valid
  end
end
