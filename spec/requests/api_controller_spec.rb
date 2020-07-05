require 'rails_helper'

RSpec.describe ApiController do
  def make_request(url, params = nil)
    get(url)
  end

  describe 'GET /index' do
    it 'returns 200 and contains desired results' do
      make_request(api_url, { "shopify_domain": 'www.test_domain.com' })

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to have_key('result')
    end
  end

  describe 'GET ping' do
    it 'renders correct response' do
      make_request(ping_url)

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq("ok" => true)
    end
  end
end
