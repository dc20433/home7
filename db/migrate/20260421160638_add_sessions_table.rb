class AddSessionsTable < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:sessions)
      create_table :sessions do |t|
        t.string :session_id, null: false
        t.text :data
        t.timestamps
      end
    end

    # Only add indexes if the columns actually exist in the table
    if column_exists?(:sessions, :session_id) && !index_exists?(:sessions, :session_id)
      add_index :sessions, :session_id, unique: true
    end
    
    if column_exists?(:sessions, :updated_at) && !index_exists?(:sessions, :updated_at)
      add_index :sessions, :updated_at
    end
  end
end
