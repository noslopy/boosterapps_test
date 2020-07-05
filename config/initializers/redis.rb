main_uri    = ENV['REDIS_URL'] ? URI.parse(ENV['REDIS_URL']) : URI.parse("redis://127.0.0.1:6379")
sidekiq_uri = ENV['REDIS_URL'] ? URI.parse(ENV['REDIS_URL']) : URI.parse("redis://127.0.0.1:6379")

$redis = Redis.new(host: main_uri.host, port: main_uri.port, password: main_uri.password)
$sidekiq_redis = Redis.new(host: sidekiq_uri.host, port: sidekiq_uri.port, password: sidekiq_uri.password)