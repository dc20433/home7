class AddPNameToRegi < ActiveRecord::Migration[8.1]
  def change
    add_column :regis, :p_name, :string
  end
end
