require 'warden'

module Oath
  module Ironclad
    # Warden strategy to read passwords from session params.
    class LockablePasswordStrategy < ::Warden::Strategies::Base

      # Checks if strategy should be executed
      # @return [Boolean]
      def valid?
        lookup_field_value || token_field_value
      end

      # Authenticates for warden
      def authenticate!
        user = Oath.config.user_class.find_by(lookup_field => lookup_field_value)
        auth = Oath.config.authentication_service.new(user, token_field_value)
        if valid_for_auth?(user) { auth.perform }
          success!(user)
        else
          # TODO fail messages
          # if locked, give locked message
          if Adapters::BruteForce.locked? user
            fail! t('oath.ironclad.failure.locked')
          else
            fail! t('oath.ironclad.failure.could_not_log_in')
          end
          # last attempt warning?
          # else, could not log in

        end
      end

      private

      def valid_for_auth?(user, &block)
        Adapters::BruteForce.valid_for_authentication? user, &block
      end

      def lookup_field_value
        session_params[lookup_field]
      end

      def token_field_value
        session_params[token_field]
      end

      def lookup_field
        Oath.config.user_lookup_field
      end

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
