module Zahlen
  class ChangeSubscriptionPlan
    def self.call(subscription, plan)
      case subscription.payment_method
      when 'card'
        Zahlen::ConektaGateway::ChangePlan.call(subscription, plan)
      when 'cash', 'wire_transfer', 'check'
        # Add pending_payment charge to the subscription
      end
    end
  end
end
