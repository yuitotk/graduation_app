FactoryBot.define do
  factory :story_event do
    story { nil }
    title { "MyString" }
    body { "MyText" }
    position { 1 }
  end
end
