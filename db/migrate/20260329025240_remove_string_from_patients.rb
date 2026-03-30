class RemoveStringFromPatients < ActiveRecord::Migration[8.1]
  def change
    remove_column :patients, :string, :string
  end
end
