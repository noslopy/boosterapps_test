require 'pony'

BaTest::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.eager_load = false

  Pony.options = {
    :from => 'info@ba-test.com',
    :via => :smtp,
    :via_options => {
      :user_name  =>  ENV.fetch('SMTP_USERNAME'),
      :password   =>  ENV.fetch('SMTP_PASSWORD'),
      :address    =>  'smtp.mailtrap.io',
      :domain     =>  'smtp.mailtrap.io',
      :port       =>  '2525',
      :authentication => :cram_md5
    }
  }

end
