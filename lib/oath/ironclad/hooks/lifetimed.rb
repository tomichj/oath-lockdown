require 'oath/ironclad/adapters/lifetimed'


Warden::Manager.after_authentication do |user, warden, options|
  next unless user
  next unless warden.authenticated?
  warden.session()['signed_in_at'] = Time.current.utc.to_i
end


Warden::Manager.after_set_user do |user, warden, options|
  next unless user
  next unless warden.authenticated?

  lifetimed = Oath::Ironclad::Adapters::Lifetimed.new(user)
  next unless lifetimed.feature_enabled?

  signed_in_at = warden.session()['signed_in_at']
  next unless signed_in_at

  if signed_in_at.is_a? Integer
    signed_in_at = Time.at(signed_in_at).utc
  elsif signed_in_at.is_a? String
    signed_in_at = Time.parse(signed_in_at)
  end

  if lifetimed.lifetime_exceeded?(signed_in_at)
    warden.logout
    # todo set timeout message
    throw :warden, message: :lifetimed
  end
end
