module DiscountTests

  def dp_vol_discount_table_exists? url:,offer_token:
    visit(get_uri(url,{ba_test_offer_token: offer_token}))
    page.has_selector?(".ba-discount-table")
  end

  #Test if shop page working correct with volume discount
  def vd shop_url:, product_handle:, preffiled_cart_link:, offer_token:, offer_hash: nil, vd_attrs_hash: nil
    init_common offer_hash,offer_token,shop_url,preffiled_cart_link,product_handle

    @page_url     = "https://#{shop_url}/products/#{product_handle}"
    vd_attrs_hash = JSON.parse(vd_attrs_hash) if vd_attrs_hash.present?
    #Naviagate to product page
    visit_product_page

    #Check discount table presence
    @result["Discount Table Displayed"] = has_selector?(".ba-discount-table", wait: 4)

    highlight("table.ba-discount-table")
    #screenshot Product page
    shot("Product Page")

    #Check that all the rows are visible inside discount table
    if @offer_hash.present? && @result["Discount Table Displayed"]
      @result["All Rows visible"] = has_selector?('.ba-discount-table tr', :minimum => @offer_hash.count)
      within('.ba-discount-table') do |table|
        #Check if all offer tiers presented correctly
        @result["All Discount Tiers present"] = @offer_hash.all? {|offer_tier| has_content?(offer_tier["value"].to_s) }
      end
    end

    visit_preffiled_cart

    #Wait for the total field 'wh_cart_total' price present
    @result["Discounted Cart Total Displayed"] = cart_total_present?(4)
    @result["Cart Original Total Displayed"]   = has_selector?("span.wh-original-price",count: 1).present?

    highlight("span.wh-cart-total")
    shot('Preffiled Cart Page')

    #Check product quantity trigger different offer discount tier
    if (@result["Discounted Cart Total Displayed"] && @offer_hash.present?)

      min_required_quantity = @offer_hash.min_by{|e| e["qty"] }["qty"].to_i
      if (min_required_quantity > 1)
        #Enter product quantity smaller than offer requires
        set_product_quantity(min_required_quantity - 1)
        #Check if wh-cart-total hidden and if success note hidden
        @result["No Discounted Cart Total without QTY"]  = !cart_total_present?(1)
        @result["No Success message without QTY"]        = !has_content?(vd_attrs_hash["success_note"],wait: 0.5) if vd_attrs_hash.present? && vd_attrs_hash["success_note"].present?
        @result["Upsell Note displayed without QTY"]     =  has_selector?(".booster-cart-item-upsell-notes",wait: 0.5)      if vd_attrs_hash.present? && vd_attrs_hash["upsell_note"].present?
      end
      #Reset quantity to min required
      set_product_quantity(min_required_quantity)

      #Check if upsell not or success note is displayed
      if vd_attrs_hash.present?
        if (@offer_hash.count > 1)
          @result["Upsell note present for next Tier"] = has_selector?(".booster-cart-item-upsell-notes") if vd_attrs_hash["upsell_note"].present?
        else
          @result["Success note present after QTY reset"] = has_content?(vd_attrs_hash["success_note"]) if vd_attrs_hash["success_note"].present?
        end
      end
      #If there are more offer tiers make sure price is updated correctly
      if (@offer_hash.count > 1 && @result[:wh_original_price_present] && @result[:wh_cart_total_present_after_reset_quantities])
        #Temp disable because there are some issues with this check
        #Check discount for first tier
        #check_tier_discount(@offer_hash.first)
        #Check discount for second tier
        #check_tier_discount(@offer_hash.second)
      end
    end

    result
  end

  def cart_total_present? wait = 2
    has_selector?(".wh-cart-total", wait: wait,count: 1) && find(".wh-cart-total",count: 1).text.to_s.strip.present?
  rescue => ex
    false
  end

  # Basic test implementation
  def buy_x_for_y shop_url:, preffiled_cart_link:,offer_token:,offer_hash:,product_handle:
    init_common offer_hash,offer_token,shop_url,preffiled_cart_link,product_handle

    visit_preffiled_cart

    @result["Upsell Popup visible"] = has_selector?("#dpModal-container", wait: 8)
    @result["Upsell Title present"] = has_selector?("h3.upsell-title",    wait: 0.5) if @offer_hash["upsell_note"].present?

    shot('Preffiled Cart Page')

    #Click 'Add to cart' button
    find('#dpModal-container button.add-upsells',match: :first).click

    #Check cart elements
    if @shop["show_notification_bar"].to_bool.present? && @offer_hash["success_note"].present?
      @result["Notification present"] = has_selector?("#booster-notification-bar", wait: 3)
    end

    if (@offer_hash["discount_method"] != "no_discount" && @offer_hash["value"].to_i != 0)
      @result["Summary Line present"]     = has_selector?("span.booster-messages")
      @result["Discounted Price present"] = cart_total_present?
      highlight("span.wh-cart-total")
    end
    #Original price present
    @result["Original Price present"]   =  has_selector?("span.wh-original-price")
    highlight("span.wh-original-price")

    shot('Cart with Discount')

    result
  end

  def spend shop_url:,product_handle: ,offer_token: ,offer_hash:,preffiled_cart_link:
    init_common offer_hash,offer_token,shop_url,preffiled_cart_link,product_handle

    visit_product_page

    if @offer_hash["upsell_note"].present?
      @result["Upsell note on Product Page"] = has_selector?("#booster-notification-bar", wait: 5)
      highlight("#booster-notification-bar")
      shot('Product page')
    end

    visit_preffiled_cart
    check_cart_elements
    result
  end

  def buy_x_dollars shop_url:,product_handle: ,offer_token: ,offer_hash:,preffiled_cart_link:
    init_common offer_hash,offer_token,shop_url,preffiled_cart_link,product_handle

    visit_product_page
    if @offer_hash["upsell_note"].present?
      @result["Upsell note on Product Page"] = has_selector?("#booster-notification-bar", wait: 5)
      highlight("#booster-notification-bar")
      shot('Product page')
    end

    visit_preffiled_cart
    check_cart_elements

    result
  end

  def bundle shop_url:,product_handle: ,offer_token: ,offer_hash:,preffiled_cart_link:
    init_common offer_hash,offer_token,shop_url,preffiled_cart_link,product_handle

    visit_product_page

    if @offer_hash["bundle_note"].present?
      @result["Bundle Section on Product Page"] = has_selector?("div.ba-bundle-wrapper", wait: 5)
      highlight("div.ba-bundle-wrapper")
      shot('Product page')
    end

    @result["Bundle Add Button Visible"] = has_selector?("button.add-booster-bundle",wait: 1)
    #Click Add Bundle button
    #
    if @result["Bundle Add Button Visible"]
      try_click('button.add-booster-bundle:visible')
    else
      visit_preffiled_cart
    end
    has_selector?("#will_ensure_wait",wait: 2)

    visit_enabled_cart

    check_cart_elements true
    result
  end

  #Todo calculate necessary quantity
  def check_cart_elements avoid_change_qty = false
    @result["Wh Original Price present"] = has_selector?("span.wh-original-price", wait: 6)
    @result["Line Item Price present"]   = has_selector?("span.booster-cart-item-line-price") if !@mobile
    set_product_quantity(50) unless avoid_change_qty
    @result["Wh Cart Total present"]     =  has_selector?("span.wh-cart-total",wait: 6)
    highlight("span.wh-cart-total")
    shot('Preffiled Cart Page')
  end

  def result
    #All test positive
    @result.all?{|_,v| v}
  end

  private

  def init_common offer_hash,offer_token,shop_url,preffiled_link,product_handle
    @offer_hash           = JSON.parse(offer_hash) if offer_hash.present?
    @product_url          = "https://#{shop_url}/products/#{product_handle}"
    @cart_url             = "https://#{shop_url}/cart"
    @offer_params       = {ba_test_offer_token: offer_token}
    @preffiled_cart_link  = preffiled_link
  end

  def visit_product_page
    visit(get_uri(@product_url,@offer_params))
    check_password_location
  end

  def visit_preffiled_cart
    # Visit preffiled cart
    visit(get_uri(@preffiled_cart_link,@offer_params))
    check_password_location
  end

  def visit_enabled_cart
    # Visit preffiled cart
    visit(get_uri(@cart_url,@offer_params))
    check_password_location
  end

  def check_tier_discount tier
    set_product_quantity(tier["qty"])
    case tier["discount_method"]
    when 'percent'
      org_item_total = cart_original_total.to_f / tier["qty"].to_f
      dis_item_total = round_down(org_item_total.to_f * ((100 - tier["value"].to_f).to_f / 100.to_f))
      expect_total   = (dis_item_total.to_f * tier["qty"]).round(2)
      @result[:"expecte_discount_present_#{tier["discount_method"]}_#{tier["value"]}"] = (expect_total == cart_discounted_total)
      #Change offer tier and check if price is correct for this tier
    when 'fixed'
      expected_cart_total = tier["value"].to_f * tier["qty"]
      @result[:"expecte_discount_present_#{tier["discount_method"]}_#{tier["value"]}"] = (cart_discounted_total == expected_cart_total)
    when 'off'
      expected_discounted_amount = tier["value"].to_f * tier["qty"]
      @result[:"expecte_discount_present_#{tier["discount_method"]}_#{tier["value"]}"] = (cart_original_total - expected_discounted_amount).to_f.round(2) == cart_discounted_total
    end
  end

  #For cart with one item only
  def set_product_quantity qty
    #Debut mobile version
    if (has_selector?("button.btn.cart__edit--active"))
      #Click edit item
      find('button.btn.cart__edit--active',match: :first).click
      #Set quantity
      find('input.cart__qty-input',match: :first,wait: 2).set(qty.to_i)
      #Click update cart
      find("input.btn.cart__update-control,button.btn.cart__update-control,input.btn--secondary.cart__update",match: :first).click
    else
      find(cart_qty_input_selector,match: :first).set(qty.to_i)
      change_page_focus(1)
    end

    has_selector?("#will_ensure_wait",wait: 2)
  end

  def cart_original_total
    find("span.wh-original-price", match: :first).text.gsub(/[^\d,\.]/, '').strip.gsub(',',".").to_f
  end

  def cart_discounted_total
    find(".wh-cart-total", match: :first).text.gsub(/[^\d,\.]/, '').strip.gsub(',',".").to_f
  end

  def get_uri(url,params)
    uri = url.to_uri
    params.each do |k,v|
      uri.query = [uri.query, "#{k}=#{v}"].compact.join('&')
    end
    uri
  end

  def round_down amount
    amount.to_s.to_d.truncate(2).to_f
  end

end