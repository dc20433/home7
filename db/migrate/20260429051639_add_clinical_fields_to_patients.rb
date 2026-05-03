class AddClinicalFieldsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :f_list, :json unless column_exists?(:patients, :f_list)
    add_column :patients, :di_list, :json unless column_exists?(:patients, :di_list)
    add_column :patients, :com1, :string unless column_exists?(:patients, :com1)
    add_column :patients, :com2, :string unless column_exists?(:patients, :com2)
    add_column :patients, :com3, :string unless column_exists?(:patients, :com3)
    add_column :patients, :d_onset, :date unless column_exists?(:patients, :d_onset)
    add_column :patients, :pain_scale, :integer unless column_exists?(:patients, :pain_scale)
    add_column :patients, :diag_given, :string unless column_exists?(:patients, :diag_given)
    add_column :patients, :other_issues, :text unless column_exists?(:patients, :other_issues)
    add_column :patients, :preg_wks, :integer unless column_exists?(:patients, :preg_wks)
  end
end