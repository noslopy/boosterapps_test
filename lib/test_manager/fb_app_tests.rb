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

end