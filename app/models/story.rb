class Story < ApplicationRecord
  belongs_to :user
  has_many :story_events, dependent: :destroy
  has_many :story_elements, dependent: :destroy

  has_one :story_image, dependent: :destroy
  accepts_nested_attributes_for :story_image, update_only: true

  has_many :idea_placements, as: :placeable, dependent: :destroy
  has_many :placed_ideas, through: :idea_placements, source: :idea

  TITLE_MAX_LENGTH = 40

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }

  before_save :set_text_updated_at, if: :should_update_text_updated_at?

  # ✅ 見本ストーリーを削除するときだけ、その中に配置されている見本アイデア
  #    (is_sample: true)を、未配置に戻すのではなく完全に削除する。
  #    ユーザーが自分の本物のアイデアをこのストーリーに配置していた場合は
  #    対象外なので、これまで通り安全に未配置へ戻る（削除されない）。
  #    prepend: trueで、story_events等のdependent: :destroyより先に実行し、
  #    削除前のstory_events/story_elementsをまだ参照できるようにしている。
  before_destroy :destroy_placed_sample_ideas, if: :sample?, prepend: true

  # ✅ 見本ストーリーかどうか（is_sampleカラムそのもの）。
  #    要素・イベント・詳細メモ側は、ここへdelegateして同じ名前で判定できるようにする。
  def sample?
    is_sample?
  end

  private

  def should_update_text_updated_at?
    new_record? || will_save_change_to_title? || will_save_change_to_description?
  end

  def set_text_updated_at
    self.text_updated_at = Time.current
  end

  def destroy_placed_sample_ideas
    placeable_ids_by_type = {
      "Story" => [id],
      "StoryEvent" => story_events.pluck(:id),
      "StoryElement" => story_elements.pluck(:id),
      "StoryEventIdea" => StoryEventIdea.where(story_event_id: story_events.select(:id)).pluck(:id)
    }

    placeable_ids_by_type.each do |placeable_type, placeable_ids|
      next if placeable_ids.empty?

      idea_ids = IdeaPlacement.where(placeable_type: placeable_type, placeable_id: placeable_ids).select(:idea_id)
      Idea.where(id: idea_ids, is_sample: true).destroy_all
    end
  end
end
