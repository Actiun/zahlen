module Zahlen
  class CreatePlan
    def self.call(plan)
      Zahlen::ConektaGateway::CreatePlan.call(plan)
    end
  end
end
