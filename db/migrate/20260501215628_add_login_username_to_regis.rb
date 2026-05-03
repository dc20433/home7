class AddLoginUsernameToRegis < ActiveRecord::Migration[8.1]
  def change
    add_column :regis, :login_username, :string
  end
end
