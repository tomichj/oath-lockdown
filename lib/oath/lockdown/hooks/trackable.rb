require 'oath/lockdown/adapters/trackable'

# Update all standard tracked stats after each authentication.
Warden::Manager.after_set_user except: :fetch do |user, warden, _options|
  next unless user
  next unless warden.authenticated?

  trackable = Oath::Lockdown::Adapters::Trackable.new user
  next unless trackable.feature_enabled?

  trackable.update_tracked_fields!(warden.request)
end
