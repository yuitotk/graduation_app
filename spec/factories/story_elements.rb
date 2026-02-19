FactoryBot.define do
  factory :story_element do
    story { nil }
    kind { 1 }
    name { "MyString" }
    memo { "MyText" }
  end
end
