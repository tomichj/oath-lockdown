require 'warden'

module Oath
  module Lockdown
    module Strategies
      # Warden strategy that supports locking user accounts if too many invalid
      # login attempts are made.
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

        def valid_for_auth?(user, &block)
          lockable(user).valid_for_authentication? &block
        end

        def locked?(user)
          lockable(user).locked?
        end

        def lockable(user)
          @lockable ||= Oath::Lockdown::Adapters::Lockable.new(user)
        end

        def remember_me(user)
          Oath::Lockdown::Rememberable.new(@env['warden']).remember_me(user)
        end

        def remember_me?
          Oath::Lockdown::TRUE_VALUES.include? session_params[:remember_me]
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
