class AddFDateToFilings < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:filings, :f_date)
      add_column :filings, :f_date, :date
    end
  end
end
