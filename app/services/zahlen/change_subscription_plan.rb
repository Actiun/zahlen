module Zahlen
  class ChangeSubscriptionPlan
    def self.call(subscription, plan, payment_method)
      case payment_method
      when 'card'
        case Zahlen.gateway
        when 'conekta'
          change_response = Zahlen::ConektaGateway::ChangePlan.call(subscription, plan)
        end
        if change_response
          old_plan = subscription.plan
          subscription.update_attributes(plan: plan)
          subscription.instrument_plan_changed(old_plan)
        end
      else
        subscription.create_charge('pending_payment', payment_method, plan)
      end
    end
  end
end
