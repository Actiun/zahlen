module Zahlen
  module ConektaGateway
    class ChangePlan
      def self.call(subscription, plan)
        begin
          customer = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
          customer.subscription.update(plan: plan.gateway_reference_id)
          return true
        rescue Conekta::ErrorList => error_list
          errors = []
          error_list.details.each do |error_detail|
            errors << error_detail.message
          end
          subscription.update_attributes(last_error: errors.to_sentence)
          return false
        end
      end
    end
  end
end
