class FixPasswordColumnName < ActiveRecord::Migration[8.0]
  def change
    # Rename the old Devise column to the new Rails 8 column
    rename_column :users, :encrypted_password, :password_digest
  end
end
