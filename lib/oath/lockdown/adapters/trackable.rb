module Oath
  module Lockdown
    module Adapters
      #
      # Track information about your user sign ins. This module is always enabled.
      #
      # = Methods
      # * update_tracked_fields - update the user's tracked fields based on the request.
      # * update_tracked_fields! - update tracked fields and save immediately, bypassing validations
      #
      # = Columns
      # - sign_in_count - increase every time a sign in is successful
      # - current_sign_in_at - a timestamp updated at each sign in
      # - last_sign_in_at - a timestamp of the previous sign in
      # - current_sign_in_ip - the remote ip address of the user at sign in
      # - previous_sign_in_ip - the remote ip address of the previous sign in
      #
      class Trackable
        def initialize(user)
          @user = user
        end

        def feature_enabled?
          return false unless Oath.config.track_user
          [:current_sign_in_at, :current_sign_in_ip, :last_sign_in_at, :last_sign_in_ip, :sign_in_count].each do |field|
            return false unless user.respond_to?(field)
          end
          true
        end

        def update_tracked_fields(request)
          old_current = user.current_sign_in_at
          new_current = Time.now.utc
          user.last_sign_in_at     = old_current || new_current
          user.current_sign_in_at  = new_current

          old_current = user.current_sign_in_ip
          new_current = request.remote_ip
          user.last_sign_in_ip     = old_current || new_current
          user.current_sign_in_ip  = new_current

          user.sign_in_count ||= 0
          user.sign_in_count += 1
        end

        def update_tracked_fields!(request)
          update_tracked_fields(request)
          user.save(validate: false)
        end

        private

        attr_reader :user
      end
    end
  end
end
