class AddUserIdToRegis < ActiveRecord::Migration[8.1]
  def change
    # Check if the column exists before trying to add it
    unless column_exists?(:regis, :user_id)
      add_column :regis, :user_id, :integer
    end

    # Check if the index exists before trying to add it
    unless index_exists?(:regis, :user_id)
      add_index :regis, :user_id
    end
  end
end
