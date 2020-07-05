BaTest::Application.routes.draw do

  get '/api'  => 'api#index'
  post '/api' => 'api#index'

  get '/ping' => 'api#ping'
  get '/test_long_request' => 'api#test_long_request'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'boostersidekiq' && password == ENV["ADMIN_PWD"]
  end if Rails.env.production?

  mount Sidekiq::Web, at: "/sidekiq"

end
