require 'oath/ironclad/adapters/trackable'

# Update all standard tracked stats at each authentication.
Warden::Manager.after_set_user except: :fetch do |user, warden, options|
  next unless user
  next unless warden.authenticated?

  trackable = Oath::Ironclad::Adapters::Trackable.new user
  next unless trackable.feature_enabled?
  next unless trackable.required_fields?

  trackable.update_tracked_fields!(warden.request)
end
