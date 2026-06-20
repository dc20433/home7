class ChangePregnancyToBeingString < ActiveRecord::Migration[8.1]
  def up
    change_column :patients, :preg, :string,
      using: "CASE WHEN preg::text = 'true' THEN 'Yes' ELSE 'No' END"
  end

  def down
    change_column :patients, :preg, :boolean,
      using: "CASE WHEN preg = 'Yes' THEN TRUE ELSE FALSE END"
  end
end
