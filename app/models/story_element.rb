class StoryElement < ApplicationRecord
  belongs_to :story

  # 追加ここから（イベント本体用）
  has_many :story_event_elements, dependent: :destroy
  has_many :story_events, through: :story_event_elements

  # 追加ここから（詳細メモ用）
  has_many :story_event_idea_elements, dependent: :destroy
  has_many :story_event_ideas, through: :story_event_idea_elements
  # 追加ここまで

  enum :kind, { character: 0, item: 1, setting: 2 }

  validates :kind, presence: true
  validates :name, presence: true
end
