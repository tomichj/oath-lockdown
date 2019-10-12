require 'rails/generators/active_record'
require 'generators/oath/lockdown/migration/version'

module Oath
  module Lockdown
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      include Oath::Lockdown::Generators::Migration

      source_root File.expand_path("../../templates", __FILE__)

      def add_initializer
        template 'config/initializers/oath-lockdown.rb'
      end

      def add_model_migrations
        migration_template 'db/migrate/add_brute_force_to_users.rb',
                           'db/migrate/add_brute_force_to_users.rb',
                           migration_version: migration_version
        migration_template 'db/migrate/add_remember_me_to_users.rb',
                           'db/migrate/add_remember_me_to_users.rb',
                           migration_version: migration_version
        migration_template 'db/migrate/add_trackable_to_users.rb',
                           'db/migrate/add_trackable_to_users.rb',
                           migration_version: migration_version
      end

      def add_translations
        template 'config/locales/oath.lockdown.en.yml'
      end

      def self.next_migration_number(dir)
        ActiveRecord::Generators::Base.next_migration_number(dir)
      end
    end
  end
end
