module Zahlen
  module ConektaGateway
    class ChangeSubscriptionCard
      def self.call(subscription, card_token)
        begin
          customer = Zahlen::ConektaGateway::Customer.find_or_create(subscription)
          source   = customer.create_payment_source(type: "card", token_id: card_token)
          customer.subscription.update(card: source.id)
          prefix_exp_year = Time.zone.now.year.to_s[0..1]
          subscription.update_attributes(
            card_holdername: card.name,
            card_last4: card.last4,
            card_brand: card.brand,
            card_bin: card.bin,
            card_expiration: Date.new("#{prefix_exp_year}#{card.exp_year}".to_i, card.exp_month.to_i, 1)
          )
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
