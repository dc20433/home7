class RenameEmailAddressToEmail < ActiveRecord::Migration[8.1]
  def change
    # Rename it back to email
    rename_column :users, :email_address, :email
  end
end