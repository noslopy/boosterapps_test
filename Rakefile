#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require "bugsnag/integrations/rake"
#load 'tasks/emoji.rake'

Bugsnag.configure do |config|
  config.api_key = "e7b66c65de77c08a3354c405fb82b84c"
end

BaTest::Application.load_tasks
