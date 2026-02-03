require "rails_helper"

RSpec.describe User, type: :model do
  it "email と password があれば有効" do
    user = build(:user)
    expect(user).to be_valid
  end
end
