require 'warden'
require 'oath/ironclad/warden_compat'
require 'oath'
require 'oath/ironclad/version'
require 'oath/ironclad/configuration'
require 'oath/ironclad/strategies/lockable_password_strategy'
require 'oath/ironclad/strategies/remember_me_strategy'
require 'oath/ironclad/hooks/brute_force'
require 'oath/ironclad/hooks/lifetimed'
require 'oath/ironclad/hooks/timeoutable'
require 'oath/ironclad/hooks/trackable'
require 'oath/ironclad/hooks/remember_me'
require 'oath/ironclad/adapters/remember_me'
require 'oath/ironclad/controllers/proxy'
require 'oath/ironclad/controllers/remember_me_helpers'


module Oath
  module Ironclad
    autoload :FailureApp, 'oath/ironclad/failure_app'

    # Inject Ironclad's extra stuff into Oath's configuration
    Oath::Ironclad::Configuration.inject_into_oath

    # True values used to check params
    TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']
  end
end
