class CreateAiGenerations < ActiveRecord::Migration[7.0]
  def change
    # ✅ ゲストが「AI作成」を使った回数を数えるための記録。
    #    1回のAI作成につき1行だけ保存する（作られたアイデアの中身は保存しない）。
    create_table :ai_generations do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
