class AddSignedAtToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :signed_at, :datetime
  end
end
