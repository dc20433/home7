class RemoveSessionIdConstraint < ActiveRecord::Migration[8.1]
  def change
    # Only attempt to change the null constraint if the column exists
    if column_exists?(:sessions, :session_id)
      change_column_null :sessions, :session_id, true
    else
      # If the column is missing, we log a warning or skip it.
      # This prevents the migration from aborting the entire sequence.
      puts "Skipping RemoveSessionIdConstraint: column 'session_id' does not exist."
    end
  end
end
