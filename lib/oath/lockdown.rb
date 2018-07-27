require 'warden'
require 'oath'
require 'oath/lockdown/warden_compat'
require 'oath/lockdown/version'
require 'oath/lockdown/configuration'
require 'oath/lockdown/strategies/lockable_password_strategy'
require 'oath/lockdown/strategies/remember_me_strategy'
require 'oath/lockdown/hooks/brute_force'
require 'oath/lockdown/hooks/lifetimed'
require 'oath/lockdown/hooks/timeoutable'
require 'oath/lockdown/hooks/trackable'
require 'oath/lockdown/hooks/remember_me'
require 'oath/lockdown/adapters/remember_me'
require 'oath/lockdown/controller_helpers'
require 'oath/lockdown/rememberable'

module Oath
  module Lockdown
    autoload :FailureApp, 'oath/lockdown/failure_app'

    # Inject lockdown's extra stuff into Oath's configuration
    Oath::Lockdown::Configuration.inject_into_oath

    # True values used to check params
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

    # Find a user based on the vlaues from a "remember me" cookie.
    #
    # @return [User] if user is found
    # @return [nil] if no user is found
    def self.serialize_from_cookie(*args)
      id, token, generated_at = *args

      user = Oath.config.warden_serialize_from_session.call(id)
      rememberable = Oath::Lockdown::Adapters::RememberMe.new user
      user if user && rememberable.remembered?(token, generated_at)
    end

    # Serialize a user into values to be stored in a "remember me" cookie.
    #
    # @return [Array] of values to store in a cookie
    def self.serialize_into_cookie(user)
      id = Oath.config.warden_serialize_into_session.call(user)
      [id, user.remember_token, Time.current.utc.to_f.to_s]
    end

    # Is the request in a format that support browser navigation?
    #
    # @return [Boolean] true if request is in a navigable format.
    def self.is_navigational_format?(request)
      request_format ||= request.format.try(:ref)
      Oath.config.navigational_formats.include?(request_format)
    end

  end
end
