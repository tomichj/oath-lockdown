require 'oath/lockdown/adapters/lockable'

# After each sign in, if user responds to failed_attempts, sets it to 0.
# This is only triggered when the user is explicitly set (with set_user).
Warden::Manager.after_set_user except: :fetch do |user, warden, _options|
  if user.respond_to?(:failed_logins_count) && warden.authenticated?
    Oath::Lockdown::Adapters::Lockable.new(user).clear_failed_logins
  end
end
