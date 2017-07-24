module Zahlen
  class ProcessSubscription
    def self.call(uuid)
      Subscription.find_by(uuid: uuid).process!
    end
  end
end
