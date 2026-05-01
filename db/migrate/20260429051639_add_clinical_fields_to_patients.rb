class AddClinicalFieldsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :f_list, :json
    add_column :patients, :di_list, :json
    add_column :patients, :com1, :string
    add_column :patients, :com2, :string
    add_column :patients, :com3, :string
    add_column :patients, :d_onset, :date
    add_column :patients, :pain_scale, :integer
    add_column :patients, :diag_given, :string
    add_column :patients, :other_issues, :text
    add_column :patients, :preg_wks, :integer
  end
end
