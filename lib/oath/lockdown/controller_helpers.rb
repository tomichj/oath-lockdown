module Oath
  module Lockdown
    #
    # ControllerHelpers is injected into Oath's Oath::ControllerHelpers.
    # 'include Oath::ControllerHelpers' to get Oath's helpers and the helpers below.
    #
    module ControllerHelpers
      # Helper for use in before_actions where no authentication is required.
      #
      # If the user has a "remember me" cookie, this helper will use it to
      # authenticate the user. Apply this method as a before_action on
      # your session controller's #new and #create methods to
      # authenticate with their remember me cookie.
      #
      # Example:
      #   before_action :require_no_authentication, only: :new
      #
      # If the user is authenticated successfully, they'll be forwarded
      # to your root_path. This removes the need for the user to re-enter
      # their name and password.
      #
      def require_no_authentication
        return unless Oath::Lockdown.is_navigational_format?(warden.request)
        if warden.authenticate?(*Oath.config.warden_no_input_authentication_strategies) && warden.user
          flash[:alert] = I18n.t("oath.lockdown.failures.already_authenticated")
          redirect_to root_path # todo make configuratble
        end
      end
    end
  end
end
