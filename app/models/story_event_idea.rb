class StoryEventIdea < ApplicationRecord
  belongs_to :story_event
  belongs_to :idea, optional: true

  has_many :story_event_idea_elements, dependent: :destroy
  has_many :story_elements, through: :story_event_idea_elements

  # ✅ この詳細メモに「移動」してきたアイデアの配置情報。Story/StoryEvent/
  #    StoryElementには元々あったが、ここだけ抜けていたため、この詳細メモを
  #    削除しても配置情報(idea_placement)が消えずに宙ぶらりんで残ってしまう
  #    不具合があった。dependent: :destroyを付けて、同じように消えるようにする。
  has_many :idea_placements, as: :placeable, dependent: :destroy

  validates :title, presence: true

  mount_uploader :image, IdeaImageUploader

  before_save :set_text_updated_at, if: :should_update_text_updated_at?

  # ✅ この詳細メモが「見本ストーリー」に属しているか（見た目の色分けに使う）
  delegate :sample?, to: :story_event

  private

  def should_update_text_updated_at?
    new_record? || will_save_change_to_title? || will_save_change_to_memo?
  end

  def set_text_updated_at
    self.text_updated_at = Time.current
  end
end
