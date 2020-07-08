module FbAppTests

  def check_ba_discount_box_exists? url:
    visit(url)
    page.has_selector?("div.ba-discount-box")
  end

  def check_xfbml_rendered? url:
    @result = {}
    visit(url)
    @result['xfbml_attribute_rendered'] =
      page.find('div', class: 'fb-messenger-checkbox')['fb-xfbml-state'] == 'rendered'
    @result['messenger_checkbox_action_present'] = begin
      # the given form is inside a frame that has no better identifier than style
      within_frame(style: "border: none; visibility: visible; width: 280px; height: 44px;") do
        find_all('form')&.each { |f| f['action']&.include?('/plugins/messenger_checkbox/update') }.any?
      end
    end
    @result.all?{|_,v| v}
  end

  def check_atc_optin_window? url:
    @result = {}
    navigate_to_atc_optin(url)
    snap("Optin window")
    @result['optin_window_rendered'] =
      !find('.ba-fb-add-tc-popup__container').inspect.strip.empty?
    @result['send_to_messenger_button_rendered'] =
      page.find('div', class: 'fb-send-to-messenger')['fb-xfbml-state'] == 'rendered'
    @result.all?{|_,v| v}
  end

  def check_atc_optin_ignored_behaviour? url:
    @result = {}
    navigate_to_atc_optin(url)
    snap("Optin window")
    @result['optin_window_rendered'] =
      !find('.ba-fb-add-tc-popup__container').inspect.strip.empty?
    find(".ba-fb-add-tc-popup__close", match: :first)
    find('button', class: 'ba-fb-add-tc-popup__close').click
    find(".cart", match: :first)
    snap("Cart page")
    @result['navigates_to_cart_if closed_by_x'] = current_url.include? 'cart'
    navigate_to_atc_optin(url)
    find(".ba-fb-add-tc-pop-footer", match: :first)
    find('small', class: 'ba-fb-add-tc-pop-footer').click
    find(".cart", match: :first)
    @result['navigates_to_cart_if closed_by_text'] = current_url.include? 'cart'
    @result.all?{|_,v| v}
  end

  private

  def navigate_to_atc_optin url
    cleanup!
    visit(url)
    find(".ba-modal-close", match: :first).click
    find("#AddToCart-product-template", match: :first).click
    find(".ba-fb-add-tc-popup__container", match: :first)
  end

end