module Zahlen
  class CreateSubscription
    def self.call(params, owner = nil, account = nil)
      plan = params[:plan]
      payment_method = params[:payment_method]

      if payment_method == 'card'
        if params[:gateway_customer_id].present?
          customer = Conekta::Customer.find(params[:gateway_customer_id])
        end
      end

      sub = Zahlen::Subscription.new do |s|
        s.plan = plan
        s.owner = owner
        s.account = account

        s.amount_cents = plan.amount_cents
        s.amount_currency = plan.respond_to?(:amount_currency) ? plan.currency : Zahlen.default_currency
        s.quantity = params[:quantity] || 1
        s.trial_end = params[:trial_end]
        s.virtual_trial_end = params[:virtual_trial_end]

        s.payment_method = payment_method
        s.gateway = Zahlen.gateway
        s.gateway_customer_id = customer.id if customer
        s.gateway_token_id = params[:gateway_card_id]
      end

      Zahlen.queue!(Zahlen::ProcessSubscription, sub.uuid) if sub.save!

      sub
    end
  end
end
