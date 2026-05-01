class AddPasswordResetToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :needs_password_change, :boolean
  end
end
