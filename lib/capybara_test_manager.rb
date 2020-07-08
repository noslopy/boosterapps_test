require 'fileutils'
require 'test_manager/discount_tests'
require 'test_manager/fb_app_tests'
require 'test_manager/currency_exchange'
require 'test_manager/compliance_checks'
require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'aws-sdk-s3'


TEST_MODULES = [
  DiscountTests, FbAppTests, CurrencyExchange, ComplianceChecks
]

class CapybaraTestManager
  USER_AGENT = 'Bot'.freeze

  TEST_MODULES.each{|m| include m }

  def initialize(domain = '', current_driver = :chrome_headless, mobile = false)
    @mobile  =  mobile
    app_host = 'http://www.google.com' #start page
    @result = {} #test results
    @initialized = false
    @domain = domain
    #Important: Capybara by default will look for visible elements only!
    get_test_methods
    #Temp solution to allow check for mobile screen sizes
    current_driver = :selenium_chrome_headless
    Capybara.current_driver = current_driver

    #initialize session
    @session = Capybara::Session.new(current_driver)
    @session.driver.options[:options].add_argument("user-agent=\"#{USER_AGENT}\"")
    # Set User-Agent
    if (@mobile)
      @session.driver.browser.manage.window.resize_to(347,618)
    else
      @session.driver.browser.manage.window.resize_to(1366,768)
    end
  rescue => ex
    Rails.logger.info "EX=#{ex.message} trace=#{ex.backtrace}"
  end

  def reset_session
    Capybara.reset_sessions!
    Capybara.use_default_driver
    @session.driver.quit
  end

  def add_to_cart_selector
    @add_to_cart_selector ||= ['#AddToCart-product-template',
                               '.product-atc-btn',
                               '.product-menu-button.product-menu-button-atc',
                               '.button-cart',
                               '.product-add',
                               '.add-to-cart input',
                               '.btn-addtocart',
                               '[name=add]'].join(',')
    @add_to_cart_selector
  end

  def cart_qty_input_selector
    @cart_qty_input ||= ["input.cart__qty-input",
                         "input.qty-remove-defaults",
                         "input.quantity-selector",
                         "input.js-qty__num",
                         "input.cart__quantity-selector",
                         "input.cart-item__qty-input",
                         "input.js--num",
                         "input.cart__product-qty",
                         "input[id^=updates].number_val_input",
                         "input[id^=updates].quantity",
                         "input[id^=updates].QuantitySelector__CurrentQuantity",
                         "input[id^=updates]"].join(',')
     @cart_qty_input
  end

  #extract the list of methods from all test modules
  def get_test_methods
    obj       =  Object.new
    i_methods = obj.public_methods
    TEST_MODULES.each{|m|  obj.extend(m) }
    @test_methods = (obj.public_methods - i_methods).map &:to_s
  end

  #This method allows to execute any test method from TestManager additional modules
  def execute_test(test_method, params)
    @shop          = params["shop_hash"].present? ? JSON.parse(params["shop_hash"]) : {}
    @r             = {}
    @error_msg     = nil
    @test_positive = false
    begin
      if @test_methods.include?(test_method)
        #Get test_method arguments
        method_args = self.method(test_method).parameters.map(&:last)
        #Select only necessary params for test_method
        args =  params.symbolize_keys.select{|k| method_args.include?(k)}
        #Execute test method
        result = self.send(test_method,args)
        @test_positive = result if [TrueClass, FalseClass].include? result.class
      else
        @error_msg = "Test method missing!"
      end
    rescue => ex
      msg = ex.message
      @error_msg = "Something went wrong ex=#{msg}"
      #Todo: find a better way
      if msg.include?("already sold out") || msg.include?("unexpected alert open")
        @error_msg += "; Sold out products present"
        @test_positive = true
      end
    ensure
      reset_session
    end
    {
      "presence"    => @test_positive,
      "test_steps"  => @result,
      "tested_at"   => Time.now,
      "error_msg"   => @error_msg,
    }
  end

  def shot(title = nil)
    time = Time.now.to_i
    relative_path    = "tmp/screenshot_#{time}_#{rand(1000)}.png"
    path  = Rails.root.to_s + "/" + relative_path
    save_screenshot(relative_path)
    url =  upload_to_s3(path,relative_path)
    #delete tmp file
    FileUtils.rm(path) if File.exist?(path)
    @result["screenshots"] ||= []
    @result["screenshots"] << {s3url: url,title:  title}
  end

  def snap(title = nil)
    time = Time.now.to_i
    relative_path    = "tmp/screenshot_#{time}_#{rand(1000)}.png"
    path  = Rails.root.to_s + "/" + relative_path
    save_screenshot(relative_path)
  end


  def upload_to_s3 image_path,relative_path
    s3 = Aws::S3::Resource.new(region:'us-east-1')
    obj = s3.bucket('batest2').object(relative_path)
    result = obj.upload_file(image_path, {acl: 'public-read'})
    obj.public_url
  rescue  => e
    return "upload exception"
  end

  def login_page
    "https://#@domain/account/login"
  end

  def product_page(product)
    "https://#@domain/products/#{product}"
  end

  def change_page_focus(wait=1)
    find("body",wait: wait).click
  end

  #Proxy to @session to act as Capybara::DSL
  def method_missing(method, *args, &block)
    @session.send(method, *args, &block)
  end

  def highlight(selector)
    #a fix for chrome driver(if needed)
    #page.execute_script "window.scrollBy(0,10000)"
    execute_script("$('#{selector}').get(0).scrollIntoView(false);
                    $('#{selector}').css('outline','2px #FF0000 solid');")

  rescue => ex
    puts "Problem with highlight => #{ex.message}"
  end

  def small_scroll(y = 150, x = 0)
    execute_script "window.scrollBy(#{x},#{y})"
  rescue => ex
    puts "Problem with small_scroll =>  #{ex.message}"
  end

  def check_password_location
    if has_selector?(".template-password", wait: 1)
      @test_positive = true #Ignore password protected stores
      throw "Password access!!!"
    end

  end

  def try_click(selector)
    execute_script("$('#{selector}').click()")
  end

  def page
    @session
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        break if page.evaluate_script('typeof jQuery != "undefined" && jQuery.active == 0')
      end
    end
  end

  def self.test_key(params)
    "#{params["mobile"]}_#{params["shop_id"]}_#{params["offer_token"]}"
  end

  def self.set_result(params,result)
    Rails.logger.info "SET_RESULTS=#{result}"
    key = test_key(params)
    $redis.set(key, result.to_json)
  end

  def self.get_result(params)
    key        = test_key(params)
    result_str = $redis.get(key)
    result     = result_str.tap{|r| Rails.logger.info "RESULT=#{r}"}.present? ? JSON.parse(result_str) : result_str
  end

  def self.register_drivers
    # Capture console logs
    # Capybara.register_driver :logging_selenium_chrome do |app|
    #   caps = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs:{browser: 'ALL'})
    #   browser_options = ::Selenium::WebDriver::Chrome::Options.new()
    #   # browser_options.args << '--some_option' # add whatever browser args and other options you need (--headless, etc)
    #   Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, desired_capabilities: caps)
    # end
    #
    # Most popular resolutions: 360x640,1366x768,1920x1080
    # http://gs.statcounter.com/screen-resolution-stats

    #iPhone 6
    Capybara.register_driver :chrome_mobile do |app|
      args = {}
      args[:args] = ['headless', 'no-sandbox','disable-gpu']
      options = Selenium::WebDriver::Chrome::Options.new args
      @mobile_driver = Capybara::Selenium::Driver.new(app, browser: :chrome,options: options)
      options.add_emulation(device_name: 'iPhone 6')
      @mobile_driver
    end

    # #iPhone 6/7/8
    # Capybara.register_driver :chrome_mobile do |app|
    #   @capabilities_mob = Selenium::WebDriver::Remote::Capabilities.chrome( chromeOptions: { "mobileEmulation" => { "deviceName" => "iPhone 6/7/8" },
    #                                                                                                                 args: %w[headless --no-sandbox] })
    #   Capybara::Selenium::Driver.new(app, browser: :chrome,desired_capabilities: @capabilities_mob)
    # end

    #options.add_argument("example-flag")

    #Visible driver for development
    Capybara.register_driver :chrome do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome( chromeOptions: { args: %w[--screenshot --disable-gpu  --window-size=1366,768] })
      Capybara::Selenium::Driver.new(app, browser: :chrome,desired_capabilities: capabilities)
    end

    #Not visible browser
    Capybara.register_driver :chrome_headless do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome( chromeOptions: { args: %w[headless --no-sandbox --window-size=1366,768] })
      Capybara::Selenium::Driver.new(app, browser: :chrome,desired_capabilities: capabilities)
    end

    #Not visible slow network browser
    Capybara.register_driver :selenium_chrome_headless_slow_network do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome( chromeOptions: { args: %w[headless --no-sandbox] })
      driver = Capybara::Selenium::Driver.new(app, browser: :chrome,desired_capabilities: capabilities)
      driver.browser.network_conditions ={offline: false,
                                          latency: 500,
                                          download_throughput: 10 * 2024,
                                          upload_throughput:   10 * 2024}
      driver
    end
  end

end
