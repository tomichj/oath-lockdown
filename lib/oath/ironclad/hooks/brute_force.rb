require 'oath/ironclad/adapters/brute_force'


# After each sign in, if resource responds to failed_attempts, sets it to 0
# This is only triggered when the user is explicitly set (with set_user)
Warden::Manager.after_set_user except: :fetch do |user, warden, options|
  if user.respond_to?(:failed_logins_count) && warden.authenticated?(options[:scope])
    Oath::Ironclad::Adapters::BruteForce.clear_failed_logins(user)
  end
end



Warden::Manager.after_set_user do |user, warden, options|
  Rails.logger.info "!!!!!! hook: after_set_user   event: #{options&.dig(:event)}"
  Rails.logger.info "!!!!!! options: #{options.inspect}"
end

Warden::Manager.after_authentication do |user, warden, options|
  Rails.logger.info "!!!!!! hook: after_authentication   event: #{options&.dig(:event)}"
  Rails.logger.info "!!!!!! options: #{options.inspect}"
end

Warden::Manager.after_fetch do |user, warden, options|
  Rails.logger.info "!!!!!! hook: after_fetch   event: #{options&.dig(:event)}"
  Rails.logger.info "!!!!!! options: #{options.inspect}"
end

Warden::Manager.before_failure do |env, options|
  Rails.logger.info "!!!!!! hook: before_failure   event: #{options&.dig(:event)}"
  Rails.logger.info "!!!!!! options: #{options.inspect}"
  Rails.logger.info "!!!!!! env[PATH_INFO]: #{env['PATH_INFO'].inspect}"

  params = Rack::Request.new(env).params
  Rails.logger.info "!!!!! params: #{params.inspect}"
  # Rails.logger.info "!!!!!! env: #{env.inspect}"
end

Warden::Manager.after_failed_fetch do |user, warden, options|
  Rails.logger.info "!!!!!! hook: after_failed_fetch   event: #{options&.dig(:event)}"
  Rails.logger.info "!!!!!! options: #{options.inspect}"
end

Warden::Manager.before_logout do |user, warden, options|
  Rails.logger.info "!!!!!! hook: before_logout   event: #{options&.dig(:event)}"
  Rails.logger.info "!!!!!! options: #{options.inspect}"
end

Warden::Manager.on_request do |proxy|
  Rails.logger.info "!!!!!! hook: on_request   proxy:#{proxy.inspect}"
end


