require 'oath/ironclad/adapters/timeoutable'

# Each time a record is set we check whether its session has already timed out
# or not, based on last request time. If so, the record is logged out and
# redirected to the sign in page. Also, each time the request comes and the
# record is set, we set the last request time inside its scoped session to
# verify timeout in the following request.
Warden::Manager.after_set_user do |user, warden, options|
  next unless user
  next unless warden.authenticated?

  timeoutable = Oath::Ironclad::Adapters::Timeoutable.new(user)
  next unless timeoutable.feature_enabled?

  last_request_at = warden.session()['last_request_at']
  if last_request_at.is_a? Integer
    last_request_at = Time.at(last_request_at).utc
  elsif last_request_at.is_a? String
    last_request_at = Time.parse(last_request_at)
  end

  if timeoutable.timedout?(last_request_at)
    warden.logout
    # todo set timeout message
    throw :warden, message: I18n.t('oath.ironclad.failure.timeout')
  end

  warden.session()['last_request_at'] = Time.current.utc.to_i
end
