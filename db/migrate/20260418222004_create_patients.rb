class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.date :v_date
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :cell
      t.string :home
      t.string :work
      t.string :email
      t.string :height
      t.string :weight
      t.string :m_stat
      t.string :occup
      t.string :company
      t.string :referred
      t.string :com1
      t.string :com2
      t.string :com3
      t.string :d_onset
      t.string :pain_scale
      t.string :diag_given
      t.string :aq_b4
      t.string :di_list
      t.string :o_dis
      t.string :last_prd
      t.string :preg
      t.string :preg_wks
      t.references :regi, null: false, foreign_key: true

      t.timestamps
    end
  end
end
