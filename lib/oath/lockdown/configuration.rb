module Oath
  module Lockdown
    # Oath::Lockdown's configuration options.
    # Options are injected into oath's Configuration class, and are accessed via Oath.configure.
    #
    # Example:
    #   Oath.configure do |config|
    #     config.max_session_lifetime = 8.hours
    #   end
    #
    # TODO: document configuration options in readme?
    #
    class Configuration
      # oath-lockdown's configuration options.
      # The contents of this module will be injected into Oath::Configuration.
      module Options
        # Number of consecutive bad login attempts allowed. Commonly called "brute force protection".
        # The user's consecutive bad logins will be tracked, and if they exceed the allowed maximum,
        # the user's account will be locked. The length of the lockout is determined by
        # [#bad_login_lockout_period].
        #
        # Default is nil, which disables this feature.
        #
        #   Oath.configure do |config|
        #     config.max_consecutive_bad_logins_allowed = 4
        #     config.bad_login_lockout_period = 10.minutes
        #   end
        #
        # @return [Integer]
        attr_accessor :max_consecutive_bad_logins_allowed

        # Time period to lock an account for if the user exceeds max_consecutive_bad_logins_allowed.
        #
        # If set to nil, account is locked out indefinitely.
        #
        # @return [ActiveSupport::CoreExtensions::Numeric::Time]
        attr_accessor :bad_login_lockout_period

        # Invalidate the session after the specified period of idle time.
        #
        # Defaults to nil, which is no idle timeout.
        #
        #   Oath.configure do |config|
        #     config.timeout_in = 45.minutes
        #   end
        #
        # @return [ActiveSupport::CoreExtensions::Numeric::Time]
        attr_accessor :timeout_in

        # Allow a session to live for no more than the given elapsed time, e.g. `8.hours`.
        #
        # Defaults to nil, or no max session time.
        #
        # If set, a user session will expire once it has been active for max_session_lifetime.
        # The user session is invalidated and the next access will prompt the user for authentication.
        #
        #   Oath.configure do |config|
        #     config.max_session_lifetime = 8.hours
        #   end
        #
        # @return [ActiveSupport::CoreExtensions::Numeric::Time]
        attr_accessor :max_session_lifetime

        # Track the following for each user:
        # * current_sign_in_at
        # * current_sign_in_ip
        # * last_sign_in_at
        # * last_sign_in_ip
        # * sign_in_count
        #
        # Defaults to false, which disables tracking.
        attr_accessor :track_user

        # Rotate CSRF token on sign in if true.
        #
        # Defaults to true.
        #
        # @return [Boolean]
        attr_accessor :rotate_csrf_on_sign_in

        # The time the user will be remembered without asking for credentials again.
        #
        # Defaults to nil. Set to a period of time to enable remembering.
        #
        # @return [ActiveSupport::CoreExtensions::Numeric::Time]
        attr_accessor :remember_for

        # The name of the "remember me" cookie.
        attr_accessor :remember_cookie_name

        # If true, all the remember me tokens are going to be invalidated when the user signs out.
        attr_accessor :expire_remember_me_on_sign_out

        # If http authentication is enabled by default.
        attr_accessor :http_authenticatable

        # If http headers should be returned for ajax requests. True by default.
        attr_accessor :http_authenticatable_on_xhr

        # The realm used in Http Basic Authentication.
        attr_accessor :http_authentication_realm

        attr_accessor :remember_me_authentication_strategy, :lockable_authentication_strategy

        def setup_basic_authentication
          @http_authenticatable = false
          @http_authenticatable_on_xhr = true
          @http_authentication_realm = 'Application'
        end

        def setup_brute_force
          @max_consecutive_bad_logins_allowed = nil
          @bad_login_lockout_period = nil
        end

        def setup_timeout
          @timeout_in = nil
        end

        def setup_lifetimed
          @max_session_lifetime = nil
        end

        def setup_track_user
          @track_user = false
        end

        def setup_csrf_rotation
          @rotate_csrf_on_sign_in = true
        end

        def setup_warden_additions
          @failure_app                         = Oath::Lockdown::FailureApp
          @lockable_authentication_strategy    = Oath::Lockdown::Strategies::LockablePasswordStrategy
          @remember_me_authentication_strategy = Oath::Lockdown::Strategies::RememberMeStrategy
          @warden_authentication_strategies    = [:oath_remember_me, :oath_lockable, :oath]
        end

        def setup_rememberable
          @rememberable                   = true
          @remember_for                   = 2.weeks
          @remember_cookie_name           = 'remember_user_key'
          @expire_remember_me_on_sign_out = true
        end
      end


      # Inject oath-lockdown's configuration into oath's configuration class.
      def self.inject_into_oath
        Oath::Configuration.class_eval do
          include Oath::Lockdown::Configuration::Options

          # Rename Oath::Configuration's initialize method and invoke it in our new initialize method.
          alias_method :initialize_original, :initialize

          # Call Oath's
          def initialize
            initialize_original
            setup_basic_authentication
            setup_csrf_rotation
            setup_warden_additions
            setup_brute_force
            setup_timeout
            setup_lifetimed
            setup_track_user
            setup_rememberable
          end
        end

        # Add our warden strategy configuration to Oath::WardenSetup.
        Oath::WardenSetup.class_eval do
          # Rename Oath::WardenSetup's setup_warden_strategy method, invoke it from our setup_warden_strategy.
          alias_method :setup_warden_strategies_original, :setup_warden_strategies
          remove_method :setup_warden_strategies

          def setup_warden_strategies
            setup_warden_strategies_original
            Warden::Strategies.add :oath_lockable, Oath.config.lockable_authentication_strategy
            Warden::Strategies.add :oath_remember_me, Oath.config.remember_me_authentication_strategy
          end
        end

        Oath::ControllerHelpers.class_eval do
          include Oath::Lockdown::ControllerHelpers
        end
      end
    end
  end
end
