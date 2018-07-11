module Oath
  module Lockdown
    module Adapters
      #
      # Set a maximum allowed lifespan on a user's session, after which the session is expired and requires
      # re-authentication.
      #
      # = Configuration
      # Set the maximum session lifetime in the initializer, giving a timestamp.
      #
      #   Authenticate.configure do |config|
      #     config.max_session_lifetime = 8.hours
      #   end
      #
      # If the max_session_lifetime configuration parameter is nil, the lifetimed hook is not active.
      #
      class Lifetimed
        def initialize(user)
          @user = user
        end

        def required_fields?
          true
        end

        def feature_enabled?
          !max_session_lifetime.nil?
        end

        # Has the session reached its maximum allowed lifespan?
        def lifetime_exceeded?(signed_in_at)
          !max_session_lifetime.nil? && !signed_in_at.nil? && signed_in_at <= max_session_lifetime.ago
        end

        private

        attr_reader :user

        def max_session_lifetime
          Oath.config.max_session_lifetime
        end
      end
    end
  end
end
