module Zahlen
  module ConektaGateway
    class ChangePlan
      def self.call(subscription, plan)
        customer = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
        customer.subscription.update(plan: plan.gateway_reference_id)
      end
    end
  end
end
