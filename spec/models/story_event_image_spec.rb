require "rails_helper"

RSpec.describe StoryEventImage, type: :model do
  let(:story_event) { create(:story_event, story: create(:story, user: create(:user))) }

  it "story_event があれば有効" do
    story_event_image = build(:story_event_image, story_event: story_event)
    expect(story_event_image).to be_valid
  end

  it "story_event が無いと無効" do
    story_event_image = build(:story_event_image, story_event: nil)
    expect(story_event_image).not_to be_valid
  end
end
