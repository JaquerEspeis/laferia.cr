# frozen_string_literal: true

module StripeStubs
  def stub_payment_intents_post_request(order:, response: {}, stripe_account_header: true)
    stub = stub_request(:post, "https://api.stripe.com/v1/payment_intents")
      .with(basic_auth: ["sk_test_12345", ""], body: /.*#{order.number}/)
    stub = stub.with(headers: { 'Stripe-Account' => 'abc123' }) if stripe_account_header
    stub.to_return(payment_intent_authorize_response_mock(response))
  end

  def stub_payment_intents_post_request_with_redirect(order:, redirect_url:)
    stub_request(:post, "https://api.stripe.com/v1/payment_intents")
      .with(basic_auth: ["sk_test_12345", ""], body: /.*#{order.number}/)
      .to_return(payment_intent_redirect_response_mock(redirect_url))
  end

  def stub_payment_intent_get_request(response: {}, stripe_account_header: true)
    stub = stub_request(:get, "https://api.stripe.com/v1/payment_intents/pi_123")
    stub = stub.with(headers: { 'Stripe-Account' => 'abc123' }) if stripe_account_header
    stub.to_return(payment_intent_authorize_response_mock(response))
  end

  def stub_payment_methods_post_request(request: { payment_method: "pm_123" }, response: {})
    stub_request(:post, "https://api.stripe.com/v1/payment_methods")
      .with(body: request,
            headers: { 'Stripe-Account' => 'abc123' })
      .to_return(hub_payment_method_response_mock(response))
  end

  # Attaches the payment method to the customer in the hub's stripe account
  def stub_payment_method_attach_request
    stub_request(:post,
                 "https://api.stripe.com/v1/payment_methods/pm_123/attach")
      .with(body: { customer: "cus_A123" })
      .to_return(hub_payment_method_response_mock({ pm_id: "pm_123" }))
  end

  # Stubs the customers call to both the main stripe account and the connected account
  def stub_customers_post_request(email:, response: {}, stripe_account_header: false)
    stub = stub_request(:post, "https://api.stripe.com/v1/customers")
      .with(body: { email: email })
    stub = stub.with(headers: { 'Stripe-Account' => 'acct_456' }) if stripe_account_header
    stub.to_return(customers_response_mock(response))
  end

  def stub_successful_capture_request(order:, response: {})
    stub_capture_request(order, payment_successful_capture_mock(response))
  end

  def stub_failed_capture_request(order:, response: {})
    stub_capture_request(order, payment_failed_capture_mock(response))
  end

  def stub_capture_request(order, response_mock)
    stub_request(:post, "https://api.stripe.com/v1/payment_intents/pi_123/capture")
      .with(body: { amount_to_capture: Spree::Money.new(order.total).cents },
            headers: { 'Stripe-Account' => 'abc123' })
      .to_return(response_mock)
  end

  def stub_refund_request
    stub_request(:post, "https://api.stripe.com/v1/charges/ch_1234/refunds")
      .with(body: { amount: 2000, expand: ["charge"] },
            headers: { 'Stripe-Account' => 'abc123' })
      .to_return(payment_successful_refund_mock)
  end

  private

  def payment_intent_authorize_response_mock(options)
    { status: options[:code] || 200,
      body: JSON.generate(id: "pi_123",
                          object: "payment_intent",
                          amount: 2000,
                          amount_received: 2000,
                          status: options[:intent_status] || "requires_capture",
                          last_payment_error: nil,
                          charges: { data: [{ id: "ch_1234", amount: 2000 }] }) }
  end

  def payment_intent_redirect_response_mock(redirect_url)
    { status: 200, body: JSON.generate(id: "pi_123",
                                       object: "payment_intent",
                                       next_source_action: {
                                         type: "authorize_with_url",
                                         authorize_with_url: { url: redirect_url }
                                       },
                                       status: "requires_source_action") }
  end

  def payment_successful_capture_mock(options)
    { status: options[:code] || 200,
      body: JSON.generate(object: "payment_intent",
                          amount: 2000,
                          charges: { data: [{ id: "ch_1234", amount: 2000 }] }) }
  end

  def payment_failed_capture_mock(options)
    { status: options[:code] || 402,
      body: JSON.generate(error: { message:
                                     options[:message] || "payment-method-failure" }) }
  end

  def hub_payment_method_response_mock(options)
    { status: options[:code] || 200,
      body: JSON.generate(id: options[:pm_id] || "pm_456", customer: "cus_A123") }
  end

  def customers_response_mock(options)
    customer_id = options[:customer_id] || "cus_A123"
    { status: 200,
      body: JSON.generate(id: customer_id,
                          sources: { data: [id: customer_id] }) }
  end

  def payment_successful_refund_mock
    { status: 200,
      body: JSON.generate(object: "refund",
                          amount: 2000,
                          charge: "ch_1234") }
  end
end
