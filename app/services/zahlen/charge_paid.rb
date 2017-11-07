module Zahlen
  class ChargePaid
    def self.call(event = nil, charge = nil)
      if charge.blank?
        charge = case Zahlen.gateway
                 when 'conekta'
                   Zahlen::ConektaGateway::Charge.find_or_create_from_event(event)
                 end
      end

      return unless charge.paid_at.blank?
      sub = charge.subscription
      case charge.payment_method
      when 'card'
        chrg = event.data['object'].with_indifferent_access
        charge.update_attributes(status: 'paid', paid_at: chrg[:paid_at])
      else
        cancel_gateway_subscription(sub)
        paid_at = Time.zone.now
        sub.activate! if sub.pending_payment?
        sub.manual_period(paid_at)
        charge.update_attributes(paid_at: paid_at)

        old_plan = sub.plan
        new_plan = charge.new_plan
        if old_plan != new_plan
          sub.instrument_plan_changed(old_plan)
          sub.update_attributes(plan: new_plan)
        end
      end

      charge
    end

    def self.cancel_gateway_subscription(sub)
      # TODO: Cancel gateway subscription to avoid double charge
    end
  end
end
