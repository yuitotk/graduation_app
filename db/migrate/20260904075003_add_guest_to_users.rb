class AddGuestToUsers < ActiveRecord::Migration[7.0]
  def change
    # ✅ このuserがゲストログインで作られたアカウントかどうかの目印
    #    デフォルトはfalse（普通に登録した人）
    add_column :users, :guest, :boolean, default: false, null: false
  end
end
