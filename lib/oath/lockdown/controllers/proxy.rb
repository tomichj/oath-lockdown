require 'oath/lockdown/controllers/remember_me_helpers'

module Oath
  module Lockdown
    module Controllers
      class Proxy
        include Oath::Lockdown::Controllers::RememberMeHelpers

        attr_reader :warden
        delegate :request, :env, to: :warden

        def initialize(warden)
          @warden = warden
        end

        def cookies
          request.cookie_jar
        end
      end
    end
  end
end
