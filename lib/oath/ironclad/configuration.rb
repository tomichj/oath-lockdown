module Oath
  module Ironclad
    class Configuration
      attr_accessor :http_authenticatable, :http_authenticatable_on_xhr, :http_authentication_realm

      def setup_basic_authentication
        @http_authenticatable = false
        @http_authenticatable_on_xhr = true
        @http_authentication_realm = 'Application'
      end

      def setup_warden_extended
        @failure_app = Oath::Ironclad::FailureApp
        Warden::Strategies.add(:params_password_strategy,
                               Authenticate2::ParamsPasswordStrategy)
      end


      def self.setup
        Oath::Configuration.class_eval do

          # slurp in the methods defined above
          include Oath::Ironclad::Configuration

          # enhance Oath configuration initialize method with our additions
          def initialize
            setup_basic_authentication

            setup_class_defaults
            setup_token_hashing
            setup_notices
            setup_services
            setup_warden
            setup_warden_extended
            setup_param_transformations
          end
        end
      end
    end
  end
end