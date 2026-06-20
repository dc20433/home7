class AddCompatibilityColumnsToPatients < ActiveRecord::Migration[8.1]
  def change
    # Define columns only if they do not exist
    [:alcohol, :aq_where, :aqrist, :better, :c_onset, :d_lost, :d_restd, 
     :diag_where, :h_when, :hosp, :inj_surg, :med_taken, :name, :o_drs, 
     :o_drs_when, :pcp_name, :string, :tobacco, :worse].each do |col|
      unless column_exists?(:patients, col)
        add_column :patients, col, :string
      end
    end
  end
end
