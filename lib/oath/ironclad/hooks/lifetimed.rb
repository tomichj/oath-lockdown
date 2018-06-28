require 'oath/ironclad/adapters/lifetimed'


Warden::Manager.after_authentication do |user, warden, options|
  next unless user
  next unless warden.authenticated?
  warden.session()['logged_in_at'] = Time.current.utc.to_i
end


Warden::Manager.after_set_user do |user, warden, options|
  next unless user
  next unless warden.authenticated?

  lifetimed = Oath::Ironclad::Adapters::Lifetimed.new(user)
  next unless lifetimed.feature_enabled?

  logged_in_at = warden.session()['logged_in_at']
  if logged_in_at.is_a? Integer
    logged_in_at = Time.at(logged_in_at).utc
  elsif logged_in_at.is_a? String
    logged_in_at = Time.parse(logged_in_at)
  end

  if lifetimed.lifetime_exceeded?(logged_in_at)
    warden.logout
    # todo set timeout message
    throw :warden, message: :lifetimed
  end
end
