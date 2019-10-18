module Warden
  module Mixins
    # Overload some "warden commons" to give us a richer Request, completed
    # with a cookie jar to allowed signed cookies, etc.
    #
    # This is sucked in via require by Oath::Lockdown, injecting it into Warden.
    module Common
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
  end
end
