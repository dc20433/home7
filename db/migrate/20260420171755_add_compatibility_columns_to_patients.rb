class AddCompatibilityColumnsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :alcohol, :string
    add_column :patients, :aq_where, :string
    add_column :patients, :aqrist, :string
    add_column :patients, :better, :string
    add_column :patients, :c_onset, :string
    add_column :patients, :d_lost, :string
    add_column :patients, :d_restd, :string
    add_column :patients, :diag_where, :string
    add_column :patients, :h_when, :string
    add_column :patients, :hosp, :string
    add_column :patients, :inj_surg, :string
    add_column :patients, :med_taken, :string
    add_column :patients, :name, :string
    add_column :patients, :o_drs, :string
    add_column :patients, :o_drs_when, :string
    add_column :patients, :pcp_name, :string
    add_column :patients, :string, :string
    add_column :patients, :tobacco, :string
    add_column :patients, :worse, :string
  end
end
