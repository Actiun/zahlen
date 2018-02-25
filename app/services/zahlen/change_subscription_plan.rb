module Zahlen
  class ChangeSubscriptionPlan
    def self.call(subscription, plan, payment_method)
      case payment_method
      when 'card'
        case Zahlen.gateway
        when 'conekta'
          subscription = Zahlen::ConektaGateway::ChangePlan.call(subscription, plan)
        end
        if subscription.errors.empty?
          old_plan = subscription.plan
          subscription.update_attributes(plan: plan)
          subscription.instrument_plan_changed(old_plan)
        end
      else
        subscription.create_charge('pending_payment', payment_method, plan)
      end
      subscription
    end
  end
end
