require 'warden'

module Oath
  module Ironclad
    # Warden strategy to read passwords from session params.
    class ParamsPasswordStrategy < ::Warden::Strategies::Base

      # Checks if strategy should be executed
      # @return [Boolean]
      def valid?
        lookup_field_value || token_field_value
      end

      # Authenticates for warden
      def authenticate!
        user = Oath.config.user_class.find_by(lookup_field => lookup_field_value)
        auth = Oath.config.authentication_service.new(user, token_field_value)
        auth.perform ? success!(user) : fail!("Could not log in")
      end

      private

      def lookup_field_value
        session_params[lookup_field]
      end

      def token_field_value
        session_params[token_field]
      end

      # :email
      def lookup_field
        Oath.config.user_lookup_field
      end

      # :password
      def token_field
        Oath.config.user_token_field
      end

      def session_params
        session_params = params['session']
        Oath.transform_params(session_params).symbolize_keys
      end
    end
  end
end
