FactoryBot.define do
  factory :idea do
    title { "テストタイトル" }
    memo  { "テストメモ" }
    association :user
  end
end
