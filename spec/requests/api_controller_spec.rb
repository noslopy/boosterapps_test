require 'rails_helper'

RSpec.describe ApiController do
  def get_request(url, params = nil)
    get(url, params)
  end

  describe 'FB app tests' do
    test_cases = [
      'check_ba_discount_box_exists?',
      'check_xfbml_rendered?',
      'check_popup_optin_behaviour?',
      'check_atc_optin_window?',
      'check_atc_optin_ignored_behaviour?'
    ]

    test_cases.each do |test_case|
      it "runs #{test_case}" do
        get_request(api_url, {
          shopify_domain: "booster-apps.myshopify.com",
          test_method: test_case,
          url: "https://booster-apps.myshopify.com/products/booster-apps-tee"
        })

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to have_key('result')
        expect(JSON.parse(response.body)['result']['error_msg']).to be(nil)
        expect(JSON.parse(response.body)['result']['presence']).to be(true)
      end
    end
  end



  # describe 'GET ping' do
  #   it 'renders correct response' do
  #     make_request(ping_url)

  #     expect(response.status).to eq(200)
  #     expect(JSON.parse(response.body)).to eq("ok" => true)
  #   end
  # end
end
