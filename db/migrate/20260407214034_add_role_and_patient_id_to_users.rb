class AddRoleAndPatientIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer
    add_column :users, :patient_id, :integer
  end
end
