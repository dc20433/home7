class AddOccupToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :occup, :string unless column_exists?(:patients, :occup)
    add_column :patients, :company, :string unless column_exists?(:patients, :company)
    add_column :patients, :signed_at, :datetime unless column_exists?(:patients, :signed_at)
    
    # Add the missing consent column
    # Assuming this is a boolean (true/false) for the consent checkbox
    add_column :patients, :patient_consent, :boolean, default: false unless column_exists?(:patients, :patient_consent)
  end
end
