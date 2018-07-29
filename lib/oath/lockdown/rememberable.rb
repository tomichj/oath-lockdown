module Oath
  module Lockdown
    #
    # Handle "remember me" cookies for a user.
    #
    class Rememberable
      attr_reader :warden
      delegate :request, :env, to: :warden

      # Find a user based on the values from a "remember me" cookie.
      #
      # @return [User] if user is found
      # @return [nil] if no user is found
      def self.serialize_from_cookie(*args)
        id, token, generated_at = *args

        user = Oath.config.warden_serialize_from_session.call(id)
        remember_me = Oath::Lockdown::Adapters::Rememberable.new user
        user if user && remember_me.remembered?(token, generated_at)
      end

      # Serialize a user into values to be stored in a "remember me" cookie.
      #
      # @return [Array] of values to store in a cookie
      def self.serialize_into_cookie(user)
        id = Oath.config.warden_serialize_into_session.call(user)
        [id, user.remember_token, Time.current.utc.to_f.to_s]
      end

      def initialize(warden)
        @warden = warden
      end

      # Remembers the given user by setting up a cookie.
      def remember_me(user)
        rememberable = remember_me_adapter(user)
        rememberable.remember_me!
        cookies.signed[remember_cookie_name] = remember_cookie_values(user)
      end

      # Forgets the given resource by deleting a cookie.
      def forget_me(user)
        rememberable = remember_me_adapter(user)
        rememberable.forget_me!
        cookies.delete(remember_cookie_name, forget_cookie_values(user))
      end

      def remember_me_is_active?(user)
        _, token, generated_at = cookies.signed[remember_cookie_name]
        rememberable = remember_me_adapter(user)
        rememberable.remembered?(token, generated_at)
      end

      protected

      def remember_cookie_name
        Oath.config.remember_cookie_name
      end

      def remember_cookie_values(user)
        options = { httponly: true }
        options.merge!(base_cookie_values)
        options[:value] = Oath::Lockdown::Rememberable.serialize_into_cookie(user)
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

      def remember_me_adapter(user)
        Oath::Lockdown::Adapters::Rememberable.new user
      end
    end
  end
end
