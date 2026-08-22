require "rails_helper"

RSpec.describe IdeaPlacement, type: :model do
  let(:user) { create(:user) }
  let(:idea) { create(:idea, user: user) }

  it "idea があれば有効（placeable は任意）" do
    placement = build(:idea_placement, idea: idea, placeable: nil)
    expect(placement).to be_valid
  end

  it "idea が無いと無効" do
    placement = build(:idea_placement, idea: nil)
    expect(placement).not_to be_valid
  end

  it "placeable にストーリーを指定できる" do
    story = create(:story, user: user)
    placement = build(:idea_placement, idea: idea, placeable: story)
    expect(placement).to be_valid
  end
end
