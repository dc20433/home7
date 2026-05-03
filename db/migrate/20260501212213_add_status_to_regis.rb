class AddStatusToRegis < ActiveRecord::Migration[8.1]
  def change
    add_column :regis, :status, :string
  end
end
