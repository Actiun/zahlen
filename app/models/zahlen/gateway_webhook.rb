module Zahlen
  class GatewayWebhook < ActiveRecord::Base
    validates_uniqueness_of :gateway_reference_id, scope: [:gateway]
  end
end
