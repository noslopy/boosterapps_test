Capybara.configure do |c|
  c.run_server            = false
  c.default_driver        = :selenium
  c.app_host              = 'http://www.google.com'
  c.default_max_wait_time = 5 #seconds
  c.default_driver        = :chrome_headless
  c.threadsafe            = true
end

#Selenium::WebDriver.logger.level = :debug

