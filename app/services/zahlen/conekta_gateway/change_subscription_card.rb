module Zahlen
  module ConektaGateway
    class ChangeSubscriptionCard
      def self.call(subscription, card_token)
        begin
          customer = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
          source   = customer.create_payment_source(type: "card", token_id: card_token)
          customer.subscription.update(card: source.id)
          subscription.sync_gateway
        rescue Conekta::Error => error
          errors = []
          for error_detail in error.details do
            errors << error_detail.message
          end
          subscription.update_attributes(last_error: errors.to_sentence)
          subscription.errors[:base] << errors.to_sentence
        end
        subscription
      end
    end
  end
end
