module Zahlen
  class SyncSubscription
    def self.call(sub)
      if sub.gateway == 'conekta'
        Zahlen::ConektaGateway::SyncSubscription.call(sub)
      end
    end
  end
end
