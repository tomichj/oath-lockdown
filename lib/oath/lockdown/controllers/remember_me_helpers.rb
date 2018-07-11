module Oath
  module Lockdown
    module Controllers
      module RememberMeHelpers
        # Remembers the given user by setting up a cookie.
        def rememeber_me(user)
          rememberable = Oath::Lockdown::Adapters::RememberMe.new user
          rememberable.remember_me!
          puts "cookie values? #{remember_cookie_values(user).inspect}"
          cookies.signed[remember_key] = remember_cookie_values(user)
        end

        # Forgets the given resource by deleting a cookie.
        def forget_me(user)
          rememberable = Oath::Lockdown::Adapters::RememberMe.new user
          rememberable.forget_me!
          cookies.delete(remember_key, forget_cookie_values(user))
        end

        def remember_me_is_active?(user)
          _, token, generated_at = cookies.signed[remember_key]
          rememberable = Oath::Lockdown::Adapters::RememberMe.new user
          rememberable.remembered?(token, generated_at)
        end

        def serialize_from_cookie(*args)
          id, token, generated_at = *args

          user = Oath.config.warden_serialize_from_session.call(id)
          rememberable = Oath::Lockdown::Adapters::RememberMe.new user
          user if user && rememberable.remembered?(token, generated_at)
        end

        def serialize_into_cookie(user)
          id = Oath.config.warden_serialize_into_session.call(user)
          [id, user.remember_token, Time.current.utc.to_f.to_s]
        end

        protected

        def remember_key
          Oath.config.remember_cookie_name
        end

        def remember_cookie_values(user)
          options = { httponly: true }
          options.merge!(cookie_values)
          options[:value] = serialize_into_cookie(user)
          options[:expires] = Oath.config.remember_for.from_now
          options
        end

        def cookie_values
          Rails.configuration.session_options.slice(:path, :domain, :secure) || {}
        end
      end
    end
  end
end
