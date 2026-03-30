class AddDetailsToRegis < ActiveRecord::Migration[8.1]
  def change
    add_column :regis, :p_name, :string
    add_column :regis, :age, :integer
  end
end
