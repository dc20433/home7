class RenameUnusedPatientFields < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        # Rename the columns to their new descriptive purposes
        rename_column :patients, :aq_where, :stress
        rename_column :patients, :string,   :exercise
        rename_column :patients, :o_drs_when,    :sleep
        rename_column :patients, :aqrist,  :all_meds
      end

      dir.down do
        # Revert back to the exact names if you ever roll back
        rename_column :patients, :stress,    :aq_where
        rename_column :patients, :exercise,  :string
        rename_column :patients, :sleep,     :o_drs_when
        rename_column :patients, :all_meds,  :aqrist
      end
    end
  end
end
