class ChangeColumnTypeInPatients < ActiveRecord::Migration[8.1]
  def change
    # Explicitly cast column to ::text before applying the regex
    [:d_lost, :d_restd, :weight, :height].each do |col|
      change_column :patients, col, :decimal, precision: 4, scale: 1, 
        using: "CASE WHEN #{col}::text ~ '^[0-9.]+$' THEN #{col}::numeric ELSE NULL END"
    end

    # Apply for dates (cast to text first)
    [:d_onset, :last_prd, :o_drs_when, :h_when].each do |col|
      change_column :patients, col, :date, 
        using: "CASE WHEN #{col}::text ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN #{col}::date ELSE NULL END"
    end
  end
end
