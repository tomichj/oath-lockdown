# Overload some "warden commons" to give us a richer Request, completed
# with a cookie jar to allowed signed cookies, etc.
module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def reset_session!
    request.reset_session
  end

  def cookies
    request.cookie_jar
  end
end
