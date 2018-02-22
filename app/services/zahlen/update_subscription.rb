module Zahlen
  class UpdateSubscription
    def self.call(event)
      case Zahlen.gateway
      when 'conekta'
        event_sub = event.data['object'].with_indifferent_access
        sub = Zahlen::Charge.where(gateway: 'conekta', gateway_reference_id: event_sub[:id])
      end
      sub.sync_gateway
    end
  end
end
