require "rails_helper"

RSpec.describe Story, type: :model do
  it "user と title があれば有効" do
    story = build(:story, user: build(:user))
    expect(story).to be_valid
  end

  it "title が無いと無効" do
    story = build(:story, user: build(:user), title: nil)
    expect(story).not_to be_valid
  end

  it "title が上限文字数を超えると無効" do
    story = build(:story, user: build(:user), title: "あ" * (Story::TITLE_MAX_LENGTH + 1))
    expect(story).not_to be_valid
  end

  it "user が無いと無効" do
    story = build(:story, user: nil)
    expect(story).not_to be_valid
  end
end
