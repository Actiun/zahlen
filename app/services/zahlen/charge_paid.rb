module Zahlen
  class ChargePaid
    def self.call(event = nil, charge = nil)
      if charge.blank?
        charge = case Zahlen.gateway
                 when 'conekta'
                   Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
                 end
      end

      return charge unless charge.payed?
      sub = charge.subscription
      case charge.payment_method
      when 'card'
        chrg = event.data['object'].with_indifferent_access
        charge.update_attributes(paid_at: chrg[:paid_at])
        charge.paid!
      else
        paid_at = Time.zone.now
        sub.activate! if sub.pending_payment?
        sub.manual_period(paid_at)
        charge.update_attributes(paid_at: paid_at)
        charge.paid! if charge.pending_payment?

        old_plan = sub.plan
        new_plan = charge.new_plan
        if old_plan != new_plan
          sub.instrument_plan_changed(old_plan)
          sub.update_attributes(plan: new_plan)
        end
      end

      charge
    end
  end
end
