module Zahlen
  class ChangeSubscriptionPlan
    def self.call(subscription, plan)
      case subscription.payment_method
      when 'card'
        Zahlen::ConektaGateway::ChangePlan.call(subscription, plan)
      else
        subscription.create_charge('pending_payment')
      end
    end
  end
end
