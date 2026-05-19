class RenameUnusedPatientFields2 < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        # Rename the columns to their new descriptive purposes for the consent block
        rename_column :patients, :better,    :signature1
        rename_column :patients, :worse,     :rep_name
        rename_column :patients, :med_taken, :vs_date
      end

      dir.down do
        # Revert back to original names on rollback
        rename_column :patients, :signature1, :better
        rename_column :patients, :rep_name,   :worse
        rename_column :patients, :vs_date,    :med_taken
      end
    end
  end
end
