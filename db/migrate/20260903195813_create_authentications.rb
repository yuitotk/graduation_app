class CreateAuthentications < ActiveRecord::Migration[7.0]
  def change
    # ✅ SNS（Google等）ログインの紐付け情報を保存するテーブル
    #    1人のuserが複数のSNSアカウントと連携できるように、usersとは別テーブルにする
    create_table :authentications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false # 例: "google"
      t.string :uid,      null: false # SNS側でのユーザー固有ID

      t.timestamps
    end

    add_index :authentications, %i[provider uid], unique: true
  end
end
