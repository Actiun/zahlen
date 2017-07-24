module Zahlen
  class StartSubscription
    attr_reader :subscription

    def self.call(subscription)
      new(subscription).run
    end

    def initialize(subscription)
      @subscription = subscription
    end

    def run
      case @subscription.payment_method
      when 'card'
        pay_with_card
      when 'cash', 'check', 'wire_transfer'
        offline_payment
      end
    end

    def pay_with_card
      begin
        customer_data = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
        customer = customer_data[:customer]
        card = customer_data[:card]

        return if subscription.errored?

        if customer.blank?
          raise 'Customer couldnt be found and its required to make the charge.'
        end

        if card.blank?
          # Get default payment source
          card = customer.payment_sources.map{|k,c| c if c.default }.compact.first
        end

        conekta_sub = customer.create_subscription({
          plan: subscription.plan.gateway_reference_id,
          card: card.id
        })

        subscription.update_attributes(
          gateway_reference_id:  conekta_sub.id,
          gateway_customer_id:  customer.id,
          current_period_start:  Time.at(conekta_sub.billing_cycle_start),
          current_period_end:    Time.at(conekta_sub.billing_cycle_end),
          ended_at:              conekta_sub.paused_at ? Time.at(conekta_sub.paused_at) : nil,
          trial_start:           conekta_sub.trial_start ? Time.at(conekta_sub.trial_start) : nil,
          trial_end:             conekta_sub.trial_end ? Time.at(conekta_sub.trial_end) : nil,
          canceled_at:           conekta_sub.canceled_at ? Time.at(conekta_sub.canceled_at) : nil,
          gateway_status:        conekta_sub.status,
        )

        card = customer.payment_sources.first
        prefix_exp_year = Time.zone.now.year.to_s[0..1]
        unless card.nil?
          subscription.update_attributes(
            card_holdername:     card.name,
            card_bin:            card.bin,
            card_last4:          card.last4,
            card_expiration:     Date.new("#{prefix_exp_year}#{card.exp_year}".to_i, card.exp_month.to_i, 1),
            card_brand:          card.respond_to?(:brand) ? card.brand : card.type,
          )
        end

        subscription.activate!
      rescue Conekta::ErrorList => error_list
        errors = []
        for error_detail in error_list.details do
          errors << error_detail.message
        end
        subscription.update_attributes(last_error: errors.to_sentence)
        subscription.fail!
      rescue StandardError => e
        subscription.update_attributes(last_error: e)
        subscription.fail!
      end
    end

    def offline_payment
      # Create charge with pending_payment for manual approval
      Zahlen::Charge.create(
        subscription_id: subscription.id,
        payment_method: subscription.payment_method,
        status: 'pending_payment',
        description: subscription.plan.name,
        amount_cents: subscription.amount_cents,
        amount_currency: subscription.amount_currency
      )

      subscription.waiting!
    end
  end
end
