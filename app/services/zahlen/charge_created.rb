module Zahlen
  class ChargeCreated
    def self.call(event = nil)
      charge = case Zahlen.gateway
               when 'conekta'
                 Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
               end
      charge
    end
  end
end
