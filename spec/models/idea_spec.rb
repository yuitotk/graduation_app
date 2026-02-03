require "rails_helper"

RSpec.describe Idea, type: :model do
  it "user/title/memo があれば有効" do
    idea = build(:idea)
    expect(idea).to be_valid
  end
end
