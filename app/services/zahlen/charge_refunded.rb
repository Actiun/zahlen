module Zahlen
  class ChargeRefunded
    def self.call(event = nil)
      charge = case Zahlen.gateway
               when 'conekta'
                 Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
               end
      return charge if charge.refunded?

      chrg = event.data['object'].with_indifferent_access
      refund = chrg[:refunds].first
      charge.update_attributes(refunded_at: refund[:created_at])
      charge.refund!
    end
  end
end
