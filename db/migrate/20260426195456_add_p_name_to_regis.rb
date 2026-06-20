class AddPNameToRegis < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:regis, :p_name)
      add_column :regis, :p_name, :string
    end
  end
end
