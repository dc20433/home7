class AddTrackingToUsers < ActiveRecord::Migration[8.1]
  def change
    # 1. Add is_active (defaulting to true)
    unless column_exists?(:users, :is_active)
      add_column :users, :is_active, :boolean, default: true
    end

    # 2. Add last_sign_out_at for duration logic
    unless column_exists?(:users, :last_sign_out_at)
      add_column :users, :last_sign_out_at, :datetime
    end

    # 3. Handle any other potentially missing columns safely
    [:sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip].each do |col|
      unless column_exists?(:users, col)
        # Define types for columns if they were somehow missing
        type = col == :sign_in_count ? :integer : (col.to_s.include?('ip') ? :string : :datetime)
        default = col == :sign_in_count ? 0 : nil
        add_column :users, col, type, default: default
      end
    end
  end
end
