class RecreateExerciseColumn < ActiveRecord::Migration[8.1]
  def change
    rename_column :patients, :exercise, :exercise_old
    add_column :patients, :exercise, :string
  end
end
