class AddIndexToRegisLastName < ActiveRecord::Migration[8.1]
  def change
    add_index :regis, :last_name
  end
end
