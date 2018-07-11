require 'oath/ironclad/controllers/remember_me_helpers'

module Oath
  module Ironclad
    module Controllers
      class Proxy
        include Oath::Ironclad::Controllers::RememberMeHelpers

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
