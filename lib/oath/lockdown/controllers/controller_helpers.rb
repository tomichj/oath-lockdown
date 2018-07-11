module Oath
  module Lockdown
    module ControllerHelpers
      # Helper for use in before_actions where no authentication is required.
      # 
      # If the user has a remember_me token, it will be used to seamlessly authenticate the user.
      #
      # Example:
      #   before_action :require_no_authentication, only: :new
      #
      def require_no_authentication
        # return unless is_navigational_format?
        if warden.authenticate?(:oath_remember_me) && warden.user
          flash[:alert] = I18n.t("oath.lockdown.failures.already_authenticated")
          redirect_to root_path
        end
      end
    end
  end
end