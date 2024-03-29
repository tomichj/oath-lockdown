RailsApp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.middleware.insert_after Warden::Manager, Oath::BackDoor

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
  config.eager_load = false
  config.secret_key_base = '1'
end
