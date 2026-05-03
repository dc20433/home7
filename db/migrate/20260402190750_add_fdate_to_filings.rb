class AddFdateToFilings < ActiveRecord::Migration[8.1]
  def change
    add_column :filings, :f_date, :date unless column_exists?(:filings, :f_date)
  end
end
