require "rails_helper"

RSpec.describe StoryElement, type: :model do
  let(:story) { create(:story, user: create(:user)) }

  it "story・kind・name があれば有効" do
    element = build(:story_element, story: story)
    expect(element).to be_valid
  end

  it "name が無いと無効" do
    element = build(:story_element, story: story, name: nil)
    expect(element).not_to be_valid
  end

  it "story が無いと無効" do
    element = build(:story_element, story: nil)
    expect(element).not_to be_valid
  end
end
