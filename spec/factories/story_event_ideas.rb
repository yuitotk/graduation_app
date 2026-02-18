FactoryBot.define do
  factory :story_event_idea do
    story_event { nil }
    title { "MyString" }
    memo { "MyText" }
    image { "MyString" }
    position { 1 }
  end
end
