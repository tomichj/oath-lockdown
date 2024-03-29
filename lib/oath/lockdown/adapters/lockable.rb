module Oath
  module Lockdown
    module Adapters
      #
      # Lockable can lock the user's account if there are too many failed logins.
      # This adapter is used by the lockable password strategy to lock or unlock
      # accounts.
      #
      class Lockable
        def initialize(user)
          @user = user
        end

        # Called from authentication strategies.
        #
        # Receives an optional block (to perform the actual authorization).
        def valid_for_authentication?
          return yield unless feature_enabled?

          unlock! if lock_expired?
          return true if yield && unlocked?

          failed_login!
          false
        end

        def locked?
          return false unless feature_enabled?

          !unlocked?
        end

        def clear_failed_logins
          return unless feature_enabled?

          user.update_attribute(:failed_logins_count, 0) unless user.failed_logins_count&.to_i&.zero?
        end

        protected

        def feature_enabled?
          !max_bad_logins.nil? &&
            max_bad_logins.positive? &&
            user.respond_to?(:failed_logins_count) &&
            user.respond_to?(:locked_at)
        end

        def failed_login!
          register_failed_login!
          lock! if attempts_exceeded? && unlocked?
          user.save(validate: false)
        end

        def register_failed_login!
          user.failed_logins_count ||= 0
          user.failed_logins_count += 1
        end

        def lock!
          user.update_attribute(:locked_at, Time.current.utc)
        end

        def unlock!
          user.update_attributes(failed_logins_count: 0, locked_at: nil)
        end

        # not locked at all, or was locked but lock is expired
        def unlocked?
          user.locked_at.nil? || lock_expired?
        end

        def lock_expired?
          return false unless lockout_period

          user.locked_at && user.locked_at < (Time.current.utc - lockout_period)
        end

        def attempts_exceeded?
          user.failed_logins_count > max_bad_logins
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
