require 'warden'

module Oath
  module Lockdown
    module Strategies
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
            # if remember_me is set in the request, do it.
            remember_me(user) if remember_me?
            success!(user)
          elsif locked?(user)
            fail! I18n.t('oath.lockdown.failures.locked')
          else
            fail! I18n.t('oath.lockdown.failures.could_not_log_in')
          end
          # last attempt warning?
        end

        def clean_up_csrf?
          true
        end

        private

        def locked?(user)
          Oath::Lockdown::Adapters::BruteForce.locked?(user)
        end

        def remember_me(user)
          Oath::Lockdown::Controllers::Proxy.new(@env['warden']).rememeber_me(user)
        end

        def remember_me?
          Oath::Lockdown::TRUE_VALUES.include? session_params[:remember_me]
        end

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
end
