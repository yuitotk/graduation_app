require "rails_helper"

RSpec.describe Idea, type: :model do
  it "user/title/memo があれば有効" do
    idea = build(:idea)
    expect(idea).to be_valid
  end

  it "title が無いと無効" do
    idea = build(:idea, title: nil)
    expect(idea).not_to be_valid
  end

  it "title が上限文字数を超えると無効" do
    idea = build(:idea, title: "あ" * (Idea::TITLE_MAX_LENGTH + 1))
    expect(idea).not_to be_valid
  end

  it "memo が無いと無効" do
    idea = build(:idea, memo: nil)
    expect(idea).not_to be_valid
  end

  it "user が無いと無効" do
    idea = build(:idea, user: nil)
    expect(idea).not_to be_valid
  end
end
