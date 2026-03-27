class AddDetailsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :com1, :string
    add_column :patients, :com2, :string
    add_column :patients, :com3, :string
  end
end
