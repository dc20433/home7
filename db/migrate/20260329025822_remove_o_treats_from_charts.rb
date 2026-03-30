class RemoveOTreatsFromCharts < ActiveRecord::Migration[8.1]
  def change
    remove_column :charts, :o_treats, :string
  end
end
