require 'rails'
require 'oath'

require 'oath/ironclad/configuration'
require 'oath/ironclad/params_password_strategy'


module Oath
  module Ironclad
    autoload :FailureApp, 'oath/ironclad/failure_app'

    # Inject Ironclad's extra stuff into Oath's configuration
    Oath::Ironclad::Configuration.inject_into_oath
  end
end
