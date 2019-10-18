module Oath
  module Lockdown
    module Generators
      #
      # Helpers for features that depend on the rails version.
      # So far, that's just the version tag in the migration templates.
      #
      module Migration
        def rails5_and_up?
          Rails::VERSION::MAJOR >= 5
        end

        def migration_version
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if rails5_and_up?
        end
      end
    end
  end
end
