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


    # Is the request in a format that support browser navigation?
    #
    # @return [Boolean] true if request is in a navigable format.
    def self.is_navigational_format?(request)
      request_format ||= request.format.try(:ref)
      Oath.config.navigational_formats.include?(request_format)
    end

  end
end
