class AddTrackableToUsers < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :users, :current_sign_in_at, :datetime, default: nil
    add_column :users, :current_sign_in_ip, :string, default: nil, limit: 128

    add_column :users, :last_sign_in_at, :datetime, default: nil
    add_column :users, :last_sign_in_ip, :string, default: nil, limit: 128

    add_column :users, :sign_in_count, :integer, default: 0
  end
end
