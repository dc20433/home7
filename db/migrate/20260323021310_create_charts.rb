class CreateCharts < ActiveRecord::Migration[8.1]
  def change
    create_table :charts do |t|
      t.references :regi, null: false, foreign_key: true
      t.string :t_date
      t.text :subj
      t.text :obj
      t.text :assess
      t.text :plan

      t.timestamps
    end
  end
end
