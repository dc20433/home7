class FixPasswordColumnName < ActiveRecord::Migration[8.0]
  def change
    # Only rename if the column actually exists in the current schema
    if column_exists?(:users, :encrypted_password)
      rename_column :users, :encrypted_password, :password_digest
    end
    
    # Ensure the column exists regardless of its original name
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string
    end
  end
end