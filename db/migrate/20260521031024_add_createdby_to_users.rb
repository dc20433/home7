class AddCreatedbyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :created_by, :string
  end
end
