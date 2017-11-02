module Zahlen
  module ConektaGateway
    class Charge
      def self.find_or_create_from_event(event)
        chrg = event.data['object'].with_indifferent_access
        charge = Zahlen::Charge.where(gateway: 'conekta', gateway_reference_id: chrg[:id])

        return charge unless charge.blank?

        sub = search_subscription(chrg)
        charge = Zahlen::Charge.create(
          subscription_id: sub.id,
          payment_method: sub.payment_method,
          new_plan: sub.plan,
          status: chrg[:status],
          description: chrg[:description],
          gateway: 'conekta',
          gateway_reference_id: chrg[:id],
          gateway_customer_id: chrg[:customer_id],
          gateway_card_id: nil,
          amount_cents: chrg[:amount],
          amount_currency: chrg[:currency],
          card_holdername: chrg.dig(:payment_method, :name),
          card_brand: chrg.dig(:payment_method, :brand),
          card_last4: chrg.dig(:payment_method, :last4),
          paid_at: chrg[:paid_at] ? Time.at(chrg[:paid_at]) : nil,
          created_at: chrg[:created_at] ? Time.at(chrg[:created_at]) : nil
        )

        charge
      end

      def self.search_subscription(charge)
        Zahlen::Subscription.where(gateway_customer_id: charge[:customer_id])
                            .order('created_at desc')
                            .first
      end
    end
  end
end
