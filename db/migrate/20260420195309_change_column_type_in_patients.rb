class ChangeColumnTypeInPatients < ActiveRecord::Migration[8.1]
  def change
    # Fix Decimals (using correct names from your \d check)
    change_column :patients, :d_lost,   :decimal, precision: 4, scale: 1, using: "NULLIF(d_lost, '')::numeric"
    change_column :patients, :d_restd,  :decimal, precision: 4, scale: 1, using: "NULLIF(d_restd, '')::numeric"
    change_column :patients, :weight,   :decimal, precision: 4, scale: 1, using: "NULLIF(weight, '')::numeric"

    # height was failing because of the 'h_' typo; fixing it here:
    change_column :patients, :height,   :decimal, precision: 3, scale: 1, using: "NULLIF(height, '')::numeric"

    # Fix Dates (including h_when)
    change_column :patients, :d_onset,    :date, using: "NULLIF(d_onset, '')::date"
    change_column :patients, :last_prd,   :date, using: "NULLIF(last_prd, '')::date"
    change_column :patients, :o_drs_when, :date, using: "NULLIF(o_drs_when, '')::date"

    # Converting h_when from string back to date to match Home2's logic
    change_column :patients, :h_when,     :date, using: "NULLIF(h_when, '')::date"

    # Fix Integers
    change_column :patients, :preg_wks, :integer, using: "NULLIF(preg_wks, '')::integer"
  end
end
