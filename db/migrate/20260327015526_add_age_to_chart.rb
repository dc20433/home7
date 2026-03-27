class AddAgeToChart < ActiveRecord::Migration[8.1]
  def change
    add_column :charts, :age, :string
  end
end
