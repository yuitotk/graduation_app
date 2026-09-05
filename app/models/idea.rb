class Idea < ApplicationRecord
  belongs_to :user

  has_one :idea_image, dependent: :destroy
  accepts_nested_attributes_for :idea_image, update_only: true

  # 既存（イベントメモ側の紐付け。残してOK）
  has_many :story_event_ideas, dependent: :nullify
  has_many :story_events, through: :story_event_ideas

  # ✅ 追加（「移動先」を1つだけ持つため）
  has_one :idea_placement, dependent: :destroy
  accepts_nested_attributes_for :idea_placement, update_only: true

  # ※任意：現在の移動先を取りたければ（使わなくてもOK）
  # has_one :placeable, through: :idea_placement, source: :placeable

  TITLE_MAX_LENGTH = 40

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
  validates :memo, presence: true

  # ✅ 見本アイデアかどうか（is_sampleカラムそのもの）
  def sample?
    is_sample?
  end

  # ✅ 今どのストーリーに配置されているか（未配置ならnil）。
  #    配置先の種類(Story/StoryEvent/StoryElement/StoryEventIdea)によって
  #    ストーリーへのたどり方が違うので、ここに1つにまとめる。
  def current_story
    placeable = idea_placement&.placeable
    return nil if placeable.blank?

    placeable.is_a?(Story) ? placeable : placeable.story
  end

  # ✅ 見本アイデアが、今まさに見本ストーリーの中に置かれているか。
  #    見本ストーリーに元から配置されていた見本アイデアだけを true にしたいので、
  #    「見本アイデアかどうか」だけでなく「今どこにあるか」も合わせて見ている。
  #    （ホームに残っている未配置の見本アイデア候補には掛からず、自由に動かせる）
  def confined_to_sample_story?
    sample? && current_story&.sample? == true
  end
end
