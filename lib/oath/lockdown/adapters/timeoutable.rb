module Oath
  module Lockdown
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
      class Timeoutable
        def initialize(user)
          @user = user
        end

        def feature_enabled?
          !timeout_in.nil?
        end

        # Has the user's session timed out?
        def timedout?(last_access)
          !timeout_in.nil? && last_access && last_access <= timeout_in.ago
        end

        private

        attr_reader :user

        def timeout_in
          Oath.config.timeout_in
        end
      end
    end
  end
end
