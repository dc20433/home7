class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
  unless column_exists?(:users, :role)
    add_column :users, :role, :string
  end
end
end
