module Oath
  module Ironclad
    #
    # Authenticate adapters wrap a user instance
    #
    module Adapters
      class BruteForce

        # Called from authenicatio strategy.
        def self.valid_for_authentication?(user)
          lockable = BruteForce.new(user)
          return yield unless lockable.feature_enabled? && lockable.required_fields?

          lockable.unlock! if lockable.lock_expired?
          return true if (yield && (!lockable.locked?))

          lockable.register_failed_login!
          lockable.lock! if lockable.attempts_exceeded? && lockable.unlocked?
          user.save(validate: false)
          false
        end

        def self.clear_failed_logins(user)
          lockable = BruteForce.new(user)
          lockable.clear_failed_logins
        end

        def initialize(user)
          @user = user
        end

        def feature_enabled?
          !max_bad_logins.nil?
        end

        def required_fields?
          user.respond_to?(:failed_logins_count) && user.respond_to?(:lock_expires_at)
        end

        def clear_failed_logins
          user.update_attribute(:failed_logins_count, 0) unless user.failed_logins_count.to_i.zero?
        end

        def register_failed_login!
          user.failed_logins_count ||= 0
          user.failed_logins_count += 1
        end

        def lock!
          user.update_attribute(:lock_expires_at, Time.current.utc + lockout_period)
        end

        def unlock!
          user.update_attributes(failed_logins_count: 0, lock_expires_at: nil)
        end

        def locked?
          !unlocked?
        end

        def unlocked? # check if lock is expired
          user.lock_expires_at.nil? || user.lock_expires_at < Time.current.utc
        end

        def lock_expired?
          user.lock_expires_at && user.lock_expires_at < Time.current.utc
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
