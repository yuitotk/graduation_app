class Idea < ApplicationRecord
  belongs_to :user

  has_one :idea_image, dependent: :destroy
  accepts_nested_attributes_for :idea_image, update_only: true

  # 既存（イベントメモ側の紐付け。残してOK）
  has_many :story_event_ideas, dependent: :nullify
  has_many :story_events, through: :story_event_ideas

  # ✅ 追加（「移動先」を1つだけ持つため）
  has_one :idea_placement, dependent: :destroy
  # ※任意：現在の移動先を取りたければ（使わなくてもOK）
  # has_one :placeable, through: :idea_placement, source: :placeable

  validates :title, presence: true
  validates :memo, presence: true
end
