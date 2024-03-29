class AddBruteForceToUsers < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :users, :failed_logins_count, :integer, default: 0
    add_column :users, :locked_at, :datetime, default: nil
  end
end
