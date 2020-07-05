if ENV['REDIS_URL'] # On heroku... or env configured deploy
  main_uri  = ENV['REDIS_URL']
else
  main_uri  = "redis://127.0.0.1:6379"
end

require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-status'

Sidekiq.default_worker_options = { backtrace: 10, retry: 3, queue: 'default' }

Sidekiq.configure_server do |config|
  config.redis = { url: main_uri, network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: main_uri, network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end


current_web_concurrency = Proc.new do
  web_concurrency = ENV['WEB_CONCURRENCY']
  web_concurrency ||= Puma.respond_to?
  (:cli_config) && Puma.cli_config.options.fetch(:max_threads)
  web_concurrency || 3
end

Sidekiq.configure_server do |config|

  #Rails.application.config.after_initialize do
  #  ActiveRecord::Base.connection_pool.disconnect!

  #  ActiveSupport.on_load(:active_record) do
  #    #config = Rails.application.config.database_configuration[Rails.env] || {}
  #    #config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
  #    #config['pool'] = ENV['DB_POOL'] || Sidekiq.options[:concurrency]
  #    ActiveRecord::Base.establish_connection("#{ENV['DATABASE_URL']}?pool=3") if ENV['DATABASE_URL']

  #    Rails.logger.info("Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
  #  end
  #end
end