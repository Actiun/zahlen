Zahlen.configure do |config|
  # Example subscription:
  #
  # config.subscribe 'zahlen.subscription.active' do |sub|
  #   Mailer.send_receipt(sub.customer.email)
  # end
  #
  # In addition to any event that the Gateway sends, you can subscribe
  # to the following special zahlen events:
  #
  #  - zahlen.<plan_type>.subscription.active
  #  - zahlen.subscription.active
  #
  # These events consume a Zahlen::Subscripion

  # Keep this subscription unless you want to disable charge tracking
  config.subscribe 'charge.paid' do |event|
    Zahlen::ChargePaid.call(event)
  end

  # Keep this subscription unless you want to disable refund handling
  config.subscribe 'charge.refunded' do |event|
    Zahlen::ChargeRefunded.call(event)
  end
end
