class AddActivatedToUsers < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:users, :activated)
      add_column :users, :activated, :boolean, default: false
    end
  end
end
