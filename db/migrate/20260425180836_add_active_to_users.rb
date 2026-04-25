class AddActiveToUsers < ActiveRecord::Migration[8.1]
def change
    # Set default to true so existing managers aren't locked out
    add_column :users, :active, :boolean, default: true, null: false
  end
end
