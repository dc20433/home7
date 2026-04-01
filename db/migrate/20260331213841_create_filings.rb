class CreateFilings < ActiveRecord::Migration[8.1]
  def change
    create_table :filings do |t|
      t.date :f_date
      t.string :image
      t.text :describe
      t.references :regi, null: false, foreign_key: true

      t.timestamps
    end
  end
end
