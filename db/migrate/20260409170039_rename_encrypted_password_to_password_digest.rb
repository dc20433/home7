class RenameEncryptedPasswordToPasswordDigest < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:users, :password_digest)
      rename_column :users, :encrypted_password, :password_digest
    end
  end
end
