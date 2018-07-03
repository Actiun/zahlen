module Zahlen
  class ChargePaid
    def self.call(event = nil)
      charge = case Zahlen.gateway
               when 'conekta'
                 Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
               end
               
      return charge if charge.payed?
      return charge unless charge.card?

      chrg = event.data['object'].with_indifferent_access
      charge.update_attributes(paid_at: chrg[:paid_at])
      charge.paid!

      charge
    end
  end
end
