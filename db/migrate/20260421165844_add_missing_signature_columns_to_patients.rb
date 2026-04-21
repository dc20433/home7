class AddMissingSignatureColumnsToPatients < ActiveRecord::Migration[8.1]
  def change
    # Check if they exist first, then add them if they don't
    add_column :patients, :signature, :text unless column_exists?(:patients, :signature)
    add_column :patients, :signed_as, :string unless column_exists?(:patients, :signed_as)
  end
end
