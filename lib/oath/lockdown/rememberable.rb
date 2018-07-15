module Oath
  module Lockdown
    #
    # Handle "remember me" cookies for a user.
    #
    class Rememberable
      attr_reader :warden
      delegate :request, :env, to: :warden

      def initialize(warden)
        @warden = warden
      end

      # Remembers the given user by setting up a cookie.
      def remember_me(user)
        rememberable = create_adapter(user)
        rememberable.remember_me!
        cookies.signed[remember_key] = remember_cookie_values(user)
      end

      # Forgets the given resource by deleting a cookie.
      def forget_me(user)
        rememberable = create_adapter(user)
        rememberable.forget_me!
        cookies.delete(remember_key, forget_cookie_values(user))
      end

      def remember_me_is_active?(user)
        _, token, generated_at = cookies.signed[remember_key]
        rememberable = create_adapter(user)
        rememberable.remembered?(token, generated_at)
      end

      protected

      def remember_key
        Oath.config.remember_cookie_name
      end

      def remember_cookie_values(user)
        options = { httponly: true }
        options.merge!(base_cookie_values)
        options[:value] = Oath::Lockdown.serialize_into_cookie(user)
        options[:expires] = Oath.config.remember_for.from_now
        options
      end

      def forget_cookie_values(_user)
        base_cookie_values
      end

      def base_cookie_values
        Rails.configuration.session_options.slice(:path, :domain, :secure) || {}
      end

      def cookies
        request.cookie_jar
      end

      def create_adapter(user)
        Oath::Lockdown::Adapters::RememberMe.new user
      end
    end
  end
end
