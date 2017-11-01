module Zahlen
  class ChangeSubscriptionPlan
    def self.call(subscription, plan, payment_method)
      case payment_method
      when 'card'
        case Zahlen.gateway
        when 'conekta'
          Zahlen::ConektaGateway::ChangePlan.call(subscription, plan)
        end
      else
        subscription.create_charge('pending_payment', payment_method, plan)
      end
    end
  end
end
