class AddNameToCharts < ActiveRecord::Migration[8.1]
  def change
    add_column :charts, :name, :string
  end
end
