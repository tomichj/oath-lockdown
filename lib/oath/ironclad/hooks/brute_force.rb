require 'oath/ironclad/adapters/brute_force'

Warden::Manager.after_authentication only: :set_user do |record, warden, options|
  Rails.logger.info "!!!!!! hook: after_set_user   event: #{options&.dig(:event)}"
  Rails.logger.info "record: #{record.inspect}"

  bf_user = Oath::Ironclad::Adapters::BruteForce.new(record)
  if bf_user.valid? && warden.authenticated?(options[:scope])
    record.update_attribute(:failed_attempts, 0) unless record.failed_attempts.to_i.zero?
  end
  # Rails.logger.info "about to throw a warden, yo"
  # warden.logout
  # throw :warden, message: "Too many login attempts"
end

Warden::Manager.after_authentication do |record, warden, options|
  Rails.logger.info "!!!!!! hook: after_authentication   event: #{options&.dig(:event)}"
  # throw :warden, message: "THIS IS THE MESSAGE FROM WARDEN I HOPE"
end

Warden::Manager.after_fetch do |record, warden, options|
  Rails.logger.info "!!!!!! hook: after_fetch   event: #{options&.dig(:event)}"
end

Warden::Manager.after_set_user do |record, warden, options|
  Rails.logger.info "!!!!!! hook: after_set_user   event: #{options&.dig(:event)}"
end

Warden::Manager.on_request do |record, warden, options|
  Rails.logger.info "!!!!!! hook: on_request   event: #{options&.dig(:event)}"
end
