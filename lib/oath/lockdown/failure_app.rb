require 'action_controller/metal'

module Oath
  module Lockdown
    class FailureApp < ActionController::Metal
      include ActionController::UrlFor
      include ActionController::Redirecting

      include Rails.application.routes.url_helpers

      delegate :flash, to: :request

      def self.call(env)
        @respond ||= action(:respond)
        @respond.call(env)
      end

      def respond
        if http_auth?
          http_auth
        elsif warden_options[:recall]
          recall
        else
          redirect
        end
      end

      private

      def http_auth
        self.status = 401
        self.headers['WWW-Authenticate'] = 'Basic realm="Application"' if http_auth_header?
        self.content_type = request.format.to_s
        self.response_body = http_auth_body
      end

      def recall
        recall_get_header_info.each do |var, value|
          recall_set_header(value, var)
        end

        if Oath::Lockdown.is_navigational_format?(request)
          flash.now[:alert] = I18n.t('oath.lockdown.failures.could_not_log_in')
        end

        self.response = recall_app(warden_options[:recall]).call(request.env)
      end

      def recall_set_header(value, var)
        if request.respond_to?(:set_header)
          request.set_header(var, value)
        else
          env[var] = value
        end
      end

      def recall_get_header_info
        config = Rails.application.config

        if config.try(:relative_url_root)
          base_path = Pathname.new(config.relative_url_root)
          full_path = Pathname.new(attempted_path)

          { "SCRIPT_NAME" => config.relative_url_root,
            "PATH_INFO"   => '/' + full_path.relative_path_from(base_path).to_s }
        else
          { "PATH_INFO" => attempted_path }
        end
      end

      def recall_app(app)
        controller, action = app.split("#")
        controller_name  = ActiveSupport::Inflector.camelize(controller)
        controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
        controller_klass.action(action)
      end

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

      def attempted_path
        warden_options[:attempted_path]
      end
    end
  end
end
