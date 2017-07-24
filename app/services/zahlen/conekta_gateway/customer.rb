module Zahlen
  module ConektaGateway
    class Customer
      def self.find_or_create(subscription)
        owner = subscription.owner

        if subscription.gateway_customer_id.present?
          # If an existing Stripe customer id is specified, use it
          gateway_customer_id = subscription.gateway_customer_id
        elsif subscription.owner
          # Look for an existing successful Subscription for the same owner, and use its gateway customer id
          gateway_customer_id = Zahlen::Subscription.where(owner: subscription.owner).where("gateway_customer_id IS NOT NULL").where("state in ('active', 'canceled')").pluck(:gateway_customer_id).first
        end

        if gateway_customer_id
          # Retrieve the customer from Stripe and use it for this subscription
          customer = Conekta::Customer.find(gateway_customer_id)
          # Add payment method if subscription have card token
          if subscription.gateway_token_id.present?
            source = customer.create_payment_source(type: 'card', token_id: subscription.gateway_token_id)
          end

          return { customer: customer, card: source }
        end

        customer = Conekta::Customer.create({
          name: subscription.owner.full_name,
          email: owner.email,
          # phone: '+52181818181'
          payment_sources: [{
            type: 'card',
            token_id: subscription.gateway_token_id
          }]
        })

        return { customer: customer }
      rescue Conekta::ErrorList => error_list
        errors = []
        for error_detail in error_list.details do
          errors << error_detail.message
        end
        subscription.update_attributes(last_error: errors.to_sentence)
        subscription.fail!
        return nil
      end
    end
  end
end
