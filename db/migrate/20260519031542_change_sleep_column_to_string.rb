class ChangeSleepColumnToString < ActiveRecord::Migration[8.1]
  def change
    change_column :patients, :sleep, :string
  end
end
