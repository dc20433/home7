class AddPatientFlagsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :activated, :boolean, default: true
  end
end
