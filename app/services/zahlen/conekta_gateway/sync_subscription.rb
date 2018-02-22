module Zahlen
  module ConektaGateway
    class SyncSubscription
      def self.call(sub)
        customer = Conekta::Customer.find(sub.gateway_customer_id)
        conekta_sub = customer.subscription

        sub.current_period_start = Time.at(conekta_sub.billing_cycle_start) if conekta_sub.try(:billing_cycle_start)
        sub.current_period_end   = Time.at(conekta_sub.billing_cycle_end) if conekta_sub.try(:billing_cycle_end)
        sub.ended_at             = Time.at(conekta_sub.ended_at) if conekta_sub.try(:ended_at)
        sub.trial_start          = Time.at(conekta_sub.trial_start) if conekta_sub.try(:trial_start)
        sub.trial_end            = Time.at(conekta_sub.trial_end) if conekta_sub.try(:trial_end)
        sub.canceled_at          = Time.at(conekta_sub.canceled_at) if conekta_sub.try(:canceled_at)
        sub.gateway_status       = conekta_sub.status
        sub.save!
      end
    end
  end
end
