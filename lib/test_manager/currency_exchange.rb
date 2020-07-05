module CurrencyExchange

  def get_exchange_rates
    currencies = ['AUD','EUR','CAD','DKK','HKD','JPY','NZD','GBP','SGD','USD']
    res = {}
    currencies.each do |c|
      url = "https://www.xe.com/currencyconverter/convert/?Amount=1&From=#{c}&To=USD"
      visit(url)
      res[c] = find("span.converterresult-toAmount",count: 1).text.to_f
    end
    res
  end

  def get_true_exchange_rates
    visit('https://averygood.myshopify.com/products/first-product?variant=30268024356938')
    find('button.btn.product-form__cart-submit',wait: 1).click
    has_selector?(".adfadfsdfsdf",wait: 2)
    find('a.cart-popup__cta-link',wait: 1).click

    find('input.cart__qty-input',match: :first,wait: 2).set(100)

    visit('https://averygood.myshopify.com/checkout')

    find('div.cart__submit-controls input.cart__submit',wait: 3).click
    find('#checkout_reduction_code',match: :first,wait: 3).set('test123')
    find('button.field__input-btn',wait: 3).click
    has_selector?(".adfadfsdfsdf", wait: 3)
    all('span.order-summary__emphasis',wait: 3).last["data-checkout-discount-amount-target"]

    #data-checkout-discount-amount-target
    currencies = ['USD','AUD','EUR','CAD','DKK','HKD','JPY','NZD','GBP','SGD']
    hash = {}

    currencies.each do |c|
      url = "https://averygood.myshopify.com/cart?currency=#{c}"
      visit(url)
      visit("https://averygood.myshopify.com/checkout")
      find('#checkout_reduction_code',match: :first,wait: 3).set('test123')
      find('button.field__input-btn',wait: 3).click
      has_selector?(".adfadfsdfsdf", wait: 2)
      value = all('span.order-summary__emphasis').last["data-checkout-discount-amount-target"]
      puts "value=#{value}"
      hash[c] = value.to_f / 10000
      hash[c] = 1 / hash[c]
    end
    hash["USD"] = 1
    hash["date"] = Time.now.to_s
    $redis.set('SHOPIFY_EXCHANGE', hash.to_json) if hash.values.present? && hash.values.length > 2 && hash.values.all?{|v| v.present? }
  end

end
