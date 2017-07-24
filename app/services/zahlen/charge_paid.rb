module Zahlen
  class ChargePaid
    def self.call(event = nil, paid_at = nil)
      charge = case Zahlen.gateway
               when 'conekta'
                 Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
               end

      return unless charge.paid_at.blank?
      case charge.payment_method
      when 'card'
        chrg = event.data['object'].with_indifferent_access
        charge.update_attributes(status: 'paid', paid_at: chrg[:paid_at])
      end
      charge
    end
  end
end
