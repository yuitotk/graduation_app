require "rails_helper"

RSpec.describe StoryImage, type: :model do
  it "story があれば有効" do
    story_image = build(:story_image, story: create(:story, user: create(:user)))
    expect(story_image).to be_valid
  end

  it "story が無いと無効" do
    story_image = build(:story_image, story: nil)
    expect(story_image).not_to be_valid
  end
end
