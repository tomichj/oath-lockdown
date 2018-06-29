require 'warden'
require 'oath'
require 'oath/ironclad/version'
require 'oath/ironclad/configuration'
require 'oath/ironclad/lockable_password_strategy'
require 'oath/ironclad/hooks/brute_force'
require 'oath/ironclad/hooks/lifetimed'
require 'oath/ironclad/hooks/timeoutable'
require 'oath/ironclad/hooks/trackable'


module Oath
  module Ironclad
    autoload :FailureApp, 'oath/ironclad/failure_app'

    # Inject Ironclad's extra stuff into Oath's configuration
    Oath::Ironclad::Configuration.inject_into_oath
  end
end
