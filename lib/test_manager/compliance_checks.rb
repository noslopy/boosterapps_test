module ComplianceChecks
  MARKETING_TEXT = <<~TEXT.squish
    I consent to receive recurring automated marketing by text message through an automatic telephone dialing system. Consent is not a condition to purchase. STOP to cancel. View Privacy Policy for more information. Msg & Data rates may apply.
  TEXT
  CHKOUT_PRIVACY_POLICY = <<~TEXT.squish
    SMS Terms & Conditions:
    Opt into SMS marketing and notifications occur by entering your phone number in the checkout page and initializing a purchase, subscribing via a subscription form, or texting a keyword. By opting into SMS marketing notifications, you agree to the following terms and conditions:
    You understand and agree that consent is not a condition for any purchase.
    You understand and agree that your phone number, name, and purchase information will be shared with our app, created by Booster Apps.
    You understand and agree that data collected will be used for sending you notifications (such as abandoned cart reminders) and targeted marketing messages. Upon sending the SMS messages, your phone number will be passed to our SMS delivery partner to fulfill the delivery of the message.
    You understand and agree that if you wish to unsubscribe from receiving further SMS marketing messages and notifications reply with STOP to any message sent from us.
    You understand and agree that other methods of opting out, such as using alternative words will not be a reasonable means of opting out.
    You understand and agree that message and data rates may apply when receiving SMS messages.
  TEXT

  def compliance_checks_for(product_handle:, domain:)
    # Open product page
    visit(product_page(product_handle))
    # Add it to cart
    #@session.find('button[aria-label="Add to cart"]').click
    @session.find('[type="submit"][name="add"]').click
    wait_for_ajax

    # Go to Checkout page
    # wait until request is complete
    visit("https://#{domain}/cart")
    @session.find('[type="submit"][name="checkout"]').click

    # do checks
    compliance_checks = {}
    # Phone Number or Email Added
    compliance_checks[:checkout_email_or_phone] = @session.has_css?('input#checkout_email_or_phone')
    # Marketing Accepted
    compliance_checks[:checkout_accepts_marketing] = @session.has_css?('input#checkout_buyer_accepts_marketing')
    # Preselect Disabled
    compliance_checks[:checkout_preselect_disabled] = if compliance_checks[:checkout_accepts_marketing]
        !@session.find('input#checkout_buyer_accepts_marketing').checked?
      else
        false
      end
    # Shipping Phone Added
    compliance_checks[:checkout_shipping_address_phone] = @session.has_css?('input#checkout_shipping_address_phone')
    # Marketing Text Updated
    compliance_checks[:marketing_text_updated] = @session.has_content?(MARKETING_TEXT)

    # Checkout Privacy Policy
    compliance_checks[:checkout_privacy_policy_updated] = begin
        link = @session.find('a[data-modal="policy-privacy-policy"]')
        @session.visit(link[:href])
        @session.has_content?(CHKOUT_PRIVACY_POLICY)
      rescue Capybara::ElementNotFound
        false
      end
    # Remove all products from the cart
    visit("https://#{domain}/cart")
    while (link = @session.find_all('a[href*="/cart/change?"]').first).present?
      link.click
      wait_for_ajax
    end
    compliance_checks
  ensure
    reset_session
  end
end
