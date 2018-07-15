Oath.configure do |config|
  # Enable 'brute force' protection - lock accounts on repeated fails.
  #
  # config.max_consecutive_bad_logins_allowed = 4
  # config.bad_login_lockout_period = 15.minutes

  # Expire idle sessions out.
  #
  # config.timeout_in = 15.minutes

  # Expire sessions after they'be been logged in for too long.
  #
  # config.max_session_lifetime = 8.hours

  # Record a few basic facts about the user - IP address, login time.
  #
  # config.track_user = false

  # Allow 'remember me' settings.
  #
  # config.remember_for = 2.weeks
  # config.expire_remember_me_on_sign_out = true
  # config.remember_cookie_name = 'remember_user_key'

  # Http basic authentication
  #
  # config.http_authenticatable = false
  # config.http_authenticatable_on_xhr = true
  # config.http_authentication_realm = 'Application'
end
