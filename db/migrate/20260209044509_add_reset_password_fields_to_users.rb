class AddResetPasswordFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :reset_password_token, :string unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_token_expires_at, :datetime unless column_exists?(:users,
                                                                                         :reset_password_token_expires_at)
    add_column :users, :reset_password_email_sent_at, :datetime unless column_exists?(:users, :reset_password_email_sent_at)

    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token, unique: true)
  end
end
