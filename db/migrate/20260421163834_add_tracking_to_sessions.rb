class AddTrackingToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :user_agent, :string
    add_column :sessions, :ip_address, :string
    # We also need a user_id to link the session to the user
    add_reference :sessions, :user, null: false, foreign_key: true
  end
end
