class ApiController < ActionController::API

  #TODO - INTRODUCE BASIC AUTH
  #http_basic_authenticate_with name: "capybara_api", password: ENV["CAPYBARA_API_PWD"], only: :index

  before_action :check_if_test_env

  # GET,POST /offers
  def index
    result = {}
    if params["compliance_checks"] && params["shopify_domain"] && params["product"]
      #Endpoint for checking SMS compliance on a Shopify store.
      driver = :selenium_chrome_headless
      test_manager = CapybaraTestManager.new(params["shopify_domain"], driver, false)
      result = test_manager.compliance_checks_for(
        product_handle: params[:product], domain: params["shopify_domain"]
      )
      
    elsif params["get_result"].to_bool.present?
      #Get a result for a test stored in redis. Can be deprecated after implementing a database table.
      result = CapybaraTestManager.get_result(params)

    elsif params["test_method"].present?
      #Perform a test with the params provided
      TestWorker.perform_async(params) and result = {"success" => true}

    elsif params["get_exchange"].present?
      #Endpoint for getting Shopify Currency data
      data = $redis.get('SHOPIFY_EXCHANGE')
      if data.present?
        result = {:ok => true,  data: JSON.parse(data)}
      else
        result = {:ok => false, data: {message: 'no data found!'}}
      end
    end
    Rails.logger.info "result = #{result}"
    render :json => result
  end

  def ping
    render :json => {:ok => true}
  end

  private

  def check_if_test_env
    return unless Rails.env.test?

    CapybaraTestManager.register_drivers
    mobile       = params["mobile"].to_bool
    driver       = :chrome
    test_manager = CapybaraTestManager.new(params["shopify_domain"],driver,mobile)
    result       = test_manager.execute_test(params["test_method"],params) || {}
    Rails.logger.info "result = #{result}"

    render json: { ok: true, result: result }
  end

end
