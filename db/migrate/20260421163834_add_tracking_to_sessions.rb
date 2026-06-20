class AddTrackingToSessions < ActiveRecord::Migration[8.0]
  def change
    # Check for columns before adding
    unless column_exists?(:sessions, :user_agent)
      add_column :sessions, :user_agent, :string
    end

    unless column_exists?(:sessions, :ip_address)
      add_column :sessions, :ip_address, :string
    end

    # Check for reference before adding
    unless column_exists?(:sessions, :user_id)
      add_reference :sessions, :user, null: false, foreign_key: true
    end
  end
end