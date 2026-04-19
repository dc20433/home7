class ChangePregnancyToBeingString < ActiveRecord::Migration[8.1]
  def up
    # This converts true -> 'Yes' and false -> 'No' during the change
    change_column :patients, :preg, :string, 
      using: "CASE WHEN preg IS TRUE THEN 'Yes' ELSE 'No' END"
  end

  def down
    # This allows you to go back to boolean if you ever needed to
    change_column :patients, :preg, :boolean, 
      using: "CASE WHEN preg = 'Yes' THEN TRUE ELSE FALSE END"
  end
end
