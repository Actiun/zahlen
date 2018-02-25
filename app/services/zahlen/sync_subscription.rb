module Zahlen
  class SyncSubscription
    def self.call(sub)
      case sub.gateway
      when 'conekta'
        Zahlen::ConektaGateway::SyncSubscription.call(sub)
      end
    end
  end
end
