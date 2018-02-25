module Zahlen
  module ConektaGateway
    class ChangeSubscriptionCard
      def self.call(subscription, card_token)
        begin
          customer = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
          customer.subscription.update(card: card_token)
        rescue Conekta::Error => error
          errors = []
          for error_detail in error.details do
            errors << error_detail.message
          end
          subscription.update_attributes(last_error: errors.to_sentence)
        end
        subscription
      end
    end
  end
end
