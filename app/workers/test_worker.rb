class TestWorker

  include Sidekiq::Worker

  def perform params
    CapybaraTestManager.register_drivers
    Rails.logger.info "TestWorker params=#{params}"
    mobile       = params["mobile"].to_bool
    driver       = mobile ? :chrome_mobile : :chrome_headless
    Rails.logger.info "Prepare for tests"
    test_manager = CapybaraTestManager.new(params["shopify_domain"], driver, mobile)
    Rails.logger.info "Test started"
    result       = test_manager.execute_test(params["test_method"], params) || {}
    Rails.logger.info "Test done #=#{result}"
    CapybaraTestManager.set_result(params,result)
    BrowserResult.create(data: { params: params, result: result }.to_json)
  end

end