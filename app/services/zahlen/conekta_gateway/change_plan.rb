module Zahlen
  module ConektaGateway
    class ChangePlan
      def self.call(subscription, plan)
        customer_data = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
        customer = customer_data[:customer]
        customer.subscription.update(plan: plan.gateway_reference_id)
      end
    end
  end
end
