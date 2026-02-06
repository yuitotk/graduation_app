FactoryBot.define do
  factory :inquiry do
    name { "MyString" }
    email { "MyString" }
    body { "MyText" }
    user { nil }
  end
end
