class AddFDateToFiling < ActiveRecord::Migration[8.1]
  def change
    add_column :filings, :f_date, :date
  end
end
