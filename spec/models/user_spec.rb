require "rails_helper"

RSpec.describe User, type: :model do
  it "email と password があれば有効" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "email が無いと無効" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
  end

  it "email の形式が不正だと無効" do
    user = build(:user, email: "invalid-email")
    expect(user).not_to be_valid
  end

  it "email が既に登録されていると無効" do
    create(:user, email: "duplicate@example.com")
    user = build(:user, email: "duplicate@example.com")
    expect(user).not_to be_valid
  end

  it "password が8文字未満だと無効" do
    user = build(:user, password: "short1")
    expect(user).not_to be_valid
  end
end
