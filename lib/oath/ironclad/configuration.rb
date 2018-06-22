module Oath
  module Ironclad
    # oath-ironclad's configuration options.
    # Options are injected into oath's Configuration class, and are accessed via Oath.configure.
    #
    # Example:
    #   Oath.configure do |config|
    #     config.max_session_lifetime = 8.hours
    #   end
    #
    # TODO: document configuration options
    # TODO: make ParamsPasswordStrategy a configuration option
    #
    class Configuration
      # oath-ironclad's configuration options.
      # The contents of this module will be injected into Oath::Configuration.
      module Options
        attr_accessor :http_authenticatable, :http_authenticatable_on_xhr, :http_authentication_realm
        attr_accessor :session_authentication_strategy
        attr_accessor :max_consecutive_bad_logins_allowed, :bad_login_lockout_period
        attr_accessor :timeout_in, :max_session_lifetime
        attr_accessor :password_length
        attr_accessor :reset_password_within

        def setup_basic_authentication
          @http_authenticatable = false
          @http_authenticatable_on_xhr = true
          @http_authentication_realm = 'Application'
        end

        def setup_warden_additions
          @failure_app = Oath::Ironclad::FailureApp
          @session_authentication_strategy = Oath::Ironclad::LockablePasswordStrategy
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

        def setup_password
          @password_length = 8..128
          @reset_password_within = 2.days
        end
      end


      # Inject oath-ironclad's configuration into oath's configuration class.
      def self.inject_into_oath
        Oath::Configuration.class_eval do
          include Oath::Ironclad::Configuration::Options

          # Rename Oath::Configuration's initialize method and invoke it in our new initialize method.
          alias_method :initialize_original, :initialize

          # Call Oath's
          def initialize
            initialize_original
            setup_basic_authentication
            setup_warden_additions
            setup_brute_force
            setup_timeout
            setup_lifetimed
            setup_password
          end
        end

        # Add our warden strategy configuration to Oath::WardenSetup.
        Oath::WardenSetup.class_eval do
          # Rename Oath::WardenSetup's setup_warden_strategy method, invoke it from our setup_warden_strategy.
          alias_method :setup_warden_strategies_original, :setup_warden_strategies
          remove_method :setup_warden_strategies

          def setup_warden_strategies
            setup_warden_strategies_original
            Warden::Strategies.add(:session_authentication_strategy, Oath.config.session_authentication_strategy)
          end
        end
      end
    end
  end
end
