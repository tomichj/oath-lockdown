module Oath
  module Ironclad
    module Adapters
      # Expire user sessions that have not been accessed within a certain period of time.
      # Expired users will be asked for credentials again.
      #
      # Timeoutable is enabled and configured with the `timeout_in` configuration parameter.
      # Example:
      #
      #   Oath.configure do |config|
      #     config.timeout_in = 15.minutes
      #   end
      #
      # = Columns
      # No columns are required on the user table.
      #
      # = Configuration
      # * timeout_in - maximum idle time allowed before session is invalidated. nil shuts off this feature.
      #
      # You must specify a non-nil timeout_in in your initializer to enable Timeoutable.
      #
      # = Methods
      # * timedout? - has this user timed out? @return[Boolean]
      # * timeout_in - look up timeout period in config, @return [ActiveSupport::CoreExtensions::Numeric::Time]
      #
      class Lifetimed
        extend ActiveSupport::Concern

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
