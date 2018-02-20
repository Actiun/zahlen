module Zahlen
  module ConektaGateway
    class ChangePlan
      def self.call(subscription, plan)
        begin
          customer = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
          customer.subscription.update(plan: plan.gateway_reference_id)
          return true
        rescue Conekta::Error => error
          errors = []
          for error_detail in error.details do
            errors << error_detail.message
          end
          subscription.update_attributes(last_error: errors.to_sentence)
          return false
        end
      end
    end
  end
end
