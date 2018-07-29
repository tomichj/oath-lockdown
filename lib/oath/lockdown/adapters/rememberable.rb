module Oath
  module Lockdown
    module Adapters
      class Rememberable
        def initialize(user)
          @user = user
        end

        def feature_enabled?
          user.respond_to?(:remember_token) && user.respond_to?(:remember_token_created_at)
        end

        # Creates a remember token and creation time.
        def remember_me!
          return unless feature_enabled?
          user.remember_token = remember_token
          user.remember_token_created_at ||= Time.current.utc
          user.save(validate: false)
        end

        def forget_me!
          return unless feature_enabled?
          return unless user.persisted?
          user.remember_token = nil
          user.remember_token_created_at = nil
          user.save(validate: false)
        end

        def remembered?(token, generated_at)
          return unless feature_enabled?
          if generated_at.is_a?(String)
            generated_at = time_from_json(generated_at)
          end

          # The token is only valid if:
          # 1. we have a date
          # 2. the current time does not pass the expiry period
          # 3. the record has a remember_created_at date
          # 4. the token date is bigger than the remember_created_at
          # 5. the token matches
          generated_at.is_a?(Time) &&
            (Oath.config.remember_for.ago < generated_at) &&
            (generated_at.utc > (user.remember_token_created_at || Time.current).utc) &&
            compare_token(user.remember_token, token)
        end

        protected

        # Generate a token checking if one does not already exist in the database.
        def remember_token
          loop do
            token = generate_token
            break token unless Oath.config.user_class.find_by(remember_token: token)
          end
        end

        # Generate a friendly string randomly to be used as token.
        # By default, length is 20 characters.
        def generate_token(length = 20)
          # To calculate real characters, we must perform this operation.
          # See SecureRandom.urlsafe_base64
          rlength = (length * 3) / 4
          SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
        end

        # constant-time comparison algorithm to prevent timing attacks
        def compare_token(a, b)
          return false if a.blank? || b.blank? || a.bytesize != b.bytesize
          l = a.unpack "C#{a.bytesize}"

          res = 0
          b.each_byte { |byte| res |= byte ^ l.shift }
          res.zero?
        end

        private

        attr_reader :user

        def time_from_json(value)
          if value =~ /\A\d+\.\d+\Z/
            Time.at(value.to_f)
          else
            Time.parse(value) rescue nil
          end
        end
      end
    end
  end
end
