module Zahlen
  class ChargePaid
    def self.call(event = nil, charge = nil, paid_at = nil)
      if charge.blank?
        charge = case Zahlen.gateway
                 when 'conekta'
                   Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
                 end
      end

      return unless charge.paid_at.blank?
      case charge.payment_method
      when 'card'
        chrg = event.data['object'].with_indifferent_access
        charge.update_attributes(status: 'paid', paid_at: chrg[:paid_at])
      else
        charge.subscription.manual_period(paid_at)
        charge.update_attributes(paid_at: paid_at)
      end
      charge
    end
  end
end
