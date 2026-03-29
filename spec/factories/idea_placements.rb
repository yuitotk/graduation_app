FactoryBot.define do
  factory :idea_placement do
    idea { nil }
    placeable { nil }
    created_here { false }
    moved_at { Time.current }
  end
end
