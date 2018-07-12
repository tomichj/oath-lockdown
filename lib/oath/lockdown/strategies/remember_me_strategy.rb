require 'warden'

module Oath
  module Lockdown
    module Strategies
      # Warden strategy to read passwords from session params.
      class RememberMeStrategy < ::Warden::Strategies::Base

        # Checks if strategy should be executed
        # @return [Boolean]
        def valid?
          @remember_cookie = nil
          remember_cookie.present?
        end

        # Authenticates for warden
        def authenticate!
          user = Oath::Lockdown.serialize_from_cookie(remember_cookie)

          if user
            success!(user)
          else
            cookies.delete(remember_key)
            pass
          end
        end

        # No need to clean up the CSRF when using rememberable.
        # In fact, cleaning it up here would be a bug because
        # rememberable is triggered on GET requests which means
        # we would render a page on first access with all csrf
        # tokens expired.
        def clean_up_csrf?
          false
        end

        private

        def remember_cookie
          @remember_cookie ||= cookies.signed[remember_key]
        end

        def remember_key
          Oath.config.remember_cookie_name
        end
      end
    end
  end
end
