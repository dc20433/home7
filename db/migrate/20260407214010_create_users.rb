class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    if table_exists?(:users)
      # Rename the old 'email' column from the dump to 'email_address'
      if column_exists?(:users, :email) && !column_exists?(:users, :email_address)
        rename_column :users, :email, :email_address
      end
    else
      create_table :users do |t|
        t.string :email_address, null: false
        t.string :password_digest, null: false
        t.timestamps
      end
    end
    
    # Now the column exists, this index will succeed
    unless index_exists?(:users, :email_address)
      add_index :users, :email_address, unique: true
    end
  end
end
