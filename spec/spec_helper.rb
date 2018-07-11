ENV["RAILS_ENV"] = "test"
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rails_app/config/environment'
require 'rspec/rails'
require 'warden'
require 'oath/ironclad'
require 'capybara'
require 'timecop'

Oath.test_mode!
Warden.test_mode!

RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.include Oath::Test::Helpers, type: :feature
  config.order = "random"
  config.after :each do
    Oath.test_reset!
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after :each do
    User.delete_all
  end
end

def with_oath_config(hash, &block)
  begin
    old_config = {}
    hash.each do |key, value|
      old_config[key] = Oath.config.send(key)
      Oath.config.send(:"#{key}=", value)
    end

    yield
  ensure

    old_config.each do |key, value|
      Oath.config.send(:"#{key}=", old_config[key])
    end
  end
end
