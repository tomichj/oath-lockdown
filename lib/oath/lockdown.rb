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
require 'oath/lockdown/controllers/proxy'
require 'oath/lockdown/controllers/remember_me_helpers'
require 'oath/lockdown/controllers/controller_helpers'

module Oath
  module Lockdown
    autoload :FailureApp, 'oath/lockdown/failure_app'

    # Inject lockdown's extra stuff into Oath's configuration
    Oath::Lockdown::Configuration.inject_into_oath

    # True values used to check params
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']
  end
end
