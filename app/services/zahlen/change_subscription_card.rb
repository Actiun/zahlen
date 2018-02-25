module Zahlen
  class ChangeSubscriptionCard
    def self.call(subscription, card_token)
      case Zahlen.gateway
      when 'conekta'
        Zahlen::ConektaGateway::ChangeSubscriptionCard.call(subscription, card_token)
      end
    end
  end
end
