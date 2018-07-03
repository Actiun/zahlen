module Zahlen
  class ChargeConfirmation
    def self.call(charge = nil)
      return charge unless charge.manual_confirmation?

      sub = charge.subscription
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

      charge
    end
  end
end
