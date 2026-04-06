class AddHealthIssuesToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :diabetes, :boolean
    add_column :patients, :hypertension, :boolean
    add_column :patients, :cancer, :boolean
    add_column :patients, :hepatitis, :boolean
    add_column :patients, :heart_disease, :boolean
    add_column :patients, :crack_cocaine, :boolean
    add_column :patients, :lymph, :boolean
    add_column :patients, :hiv_aids, :boolean
    add_column :patients, :neck_stiffness, :boolean
    add_column :patients, :seizure, :boolean
    add_column :patients, :palpitation, :boolean
    add_column :patients, :frequent_colds, :boolean
    add_column :patients, :night_sweating, :boolean
    add_column :patients, :chest_pain, :boolean
    add_column :patients, :constipation, :boolean
    add_column :patients, :excess_sweating, :boolean
    add_column :patients, :back_pain, :boolean
    add_column :patients, :depression, :boolean
    add_column :patients, :anxiety, :boolean
    add_column :patients, :ptsd, :boolean
    add_column :patients, :bypolar, :boolean
    add_column :patients, :borderline, :boolean
  end
end
