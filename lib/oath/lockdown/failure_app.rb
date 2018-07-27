require 'action_controller/metal'

module Oath
  module Lockdown
    class FailureApp < ActionController::Metal
      include ActionController::UrlFor
      include ActionController::Redirecting

      include Rails.application.routes.url_helpers
      # include Rails.application.routes.mounted_helpers

      delegate :flash, to: :request

      def self.call(env)
        @respond ||= action(:respond)
        @respond.call(env)
      end

      def respond
        if http_auth?
          http_auth
        else
          redirect
        end
      end

      def http_auth
        self.status = 401
        self.headers['WWW-Authenticate'] = 'Basic realm="Application"' if http_auth_header?
        self.content_type = request.format.to_s
        self.response_body = http_auth_body
      end

      private

      # Choose whether we should respond in a http authentication fashion,
      # including 401 and optional headers.
      #
      # This method allows the user to explicitly disable http authentication
      # on ajax requests in case they want to redirect on failures instead of
      # handling the errors on their own. This is useful in case your ajax API
      # is the same as your public API and uses a format like JSON (so you
      # cannot mark JSON as a navigational format).
      def http_auth?
        if request.xhr?
          Oath.config.http_authenticatable_on_xhr
        else
          !Oath::Lockdown.is_navigational_format?(request)
        end
      end

      # It does not make sense to send authenticate headers in ajax requests
      # or if the user disabled them.
      def http_auth_header?
        Oath.config.http_authenticatable && !request.xhr?
      end

      def http_auth_body
        warden_message
      end

      def redirect
        flash[:alert] = warden_message if warden_message
        redirect_to Oath.config.no_login_redirect
      end

      def warden
        request.respond_to?(:get_header) ? request.get_header('warden') : env['warden']
      end

      def warden_options
        request.respond_to?(:get_header) ? request.get_header('warden.options') : env['warden.options']
      end

      def warden_message
        @message ||= warden.message || warden_options[:message]
      end
    end
  end
end
