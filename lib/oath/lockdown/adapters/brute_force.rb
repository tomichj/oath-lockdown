module Oath
  module Lockdown
    #
    # Authenticate adapters wrap a user instance
    #
    module Adapters

      # Detect brute force attempts and temporarily lock a user's account if needed.
      class BruteForce

        # Called from authenication strategy.
        # Receives an optional block.
        def self.valid_for_authentication?(user)
          lockable = BruteForce.new(user)
          return yield unless lockable.feature_enabled? && lockable.required_fields?
          lockable.unlock! if lockable.lock_expired?
          return true if yield && lockable.unlocked?

          lockable.register_failed_login!
          lockable.lock! if lockable.attempts_exceeded? && lockable.unlocked?
          user.save(validate: false)
          false
        end

        def self.locked?(user)
          lockable = BruteForce.new(user)
          return false unless lockable.feature_enabled? && lockable.required_fields?
          lockable.locked?
        end

        # Call after a successful login.
        def self.clear_failed_logins(user)
          lockable = BruteForce.new(user)
          return unless lockable.feature_enabled? && lockable.required_fields?
          lockable.clear_failed_logins
        end

        def initialize(user)
          @user = user
        end

        def feature_enabled?
          !max_bad_logins.nil? && max_bad_logins > 0
        end

        def required_fields?
          user.respond_to?(:failed_logins_count) && user.respond_to?(:locked_at)
        end

        def clear_failed_logins
          user.update_attribute(:failed_logins_count, 0) unless user.failed_logins_count && user.failed_logins_count.to_i.zero?
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

        def locked?
          !unlocked?
        end

        def unlocked? # check if lock is expired
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
