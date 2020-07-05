web:  bundle exec puma -p $PORT -C ./config/puma.rb
sidekiq: RAILS_MAX_THREADS=${SIDEKIQ_RAILS_MAX_THREADS:-10} bundle exec sidekiq