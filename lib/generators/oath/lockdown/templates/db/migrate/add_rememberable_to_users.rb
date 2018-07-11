class AddRememberableToUsers < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :users, :remember_token, :string, default: nil, limit: 128
    add_column :users, :remember_token_created_at, :datetime, default: nil
  end
end
