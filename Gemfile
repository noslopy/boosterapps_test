source "https://rubygems.org"
ruby "2.5.6"

gem 'rails-api'
gem 'spring', :group => :development

gem 'hashie', '3.4.6'
gem 'sinatra', :require => nil
gem "oj", platforms: :ruby
gem 'nokogiri'

gem "bugsnag"
gem 'rabl'
gem 'chronic'
gem 'puma'
gem 'selenium-webdriver'
gem 'rack-cors', :require => 'rack/cors'
gem 'money'

gem "rest-client", require: "rest_client"
gem "capybara"
gem 'aws-sdk-s3', '~> 1'
gem 'redis-rails'
gem 'sidekiq'
gem 'sidekiq-status'
gem 'sidekiq-failures'

gem 'sequel'
gem 'pg'

gem 'pony'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem "thin"
  gem "therubyracer", platforms: :ruby
  gem "pry-rails"
  gem 'mailcatcher', require: false
  gem "figaro"
  gem 'rspec-rails', '~> 3.6'
  #gem 'database_cleaner', '~> 1.5'
  gem 'faker', '~> 1.6.1'
  gem 'factory_girl_rails', '~> 4.5.0'
end

group :production do
  gem 'rails_stdout_logging'
  gem 'rails_12factor'
end
