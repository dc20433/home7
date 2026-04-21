class RemoveSessionIdConstraint < ActiveRecord::Migration[8.1]
  def change
    # This allows Rails 8 to create sessions without the legacy column
    change_column_null :sessions, :session_id, true
  end
end
