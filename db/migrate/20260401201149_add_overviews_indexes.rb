class AddOverviewsIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :charts, :t_date
    add_index :regis, :p_name
  end
end
