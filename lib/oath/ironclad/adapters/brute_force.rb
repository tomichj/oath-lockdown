module Oath
  module Ironclad
    #
    # Authenticate adapters wrap a user instance
    #
    module Adapters
      class BruteForce
        def initialize(user)
          @user = user
        end

        def valid?
          user.respond_to?(:failed_logins_count) && user.respond_to?(:lock_expires_at)
        end

        def register_failed_login!
          user.failed_logins_count ||= 0
          user.failed_logins_count += 1
          user.lock! if user.failed_logins_count > max_bad_logins
        end

        def lock!
          user.update_attribute(:lock_expires_at, Time.now.utc + lockout_period)
          # check config for 'send_unlock_instructions' and send them?
        end

        def unlock!
          user.update_attributes(failed_logins_count: 0, lock_expires_at: nil)
        end

        def locked?
          !unlocked?
        end

        def unlocked?
          user.lock_expires_at.nil?
        end

        private

        attr_reader :user

        def max_bad_logins
          Oath.config.max_consecutive_bad_logins_allowed
        end

        def lockout_period
          Oath.config.bad_login_lockout_period
        end
      end
    end
  end
end
