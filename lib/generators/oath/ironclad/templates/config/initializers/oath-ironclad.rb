Oath.configure do |config|
  config.http_authenticatable = true
  config.http_authenticatable_on_xhr = true
  config.http_authentication_realm = 'Application'

  config.max_consecutive_bad_logins_allowed = 4
  config.bad_login_lockout_period = 15.minutes

  config.timeout_in = 15.minutes

  config.max_session_lifetime = 8.hours

  config.track_user = false

  # config.rotate_csrf_on_sign_in = true

  # config.remember_for = 2.weeks
  # config.remember_cookie_name = 'remember_user_key'
  # config.expire_remember_me_on_sign_out = true
end
