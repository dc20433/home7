class FixVDateType < ActiveRecord::Migration[8.1]
  def change
    change_column :patients, :v_date, :date
  end
end
