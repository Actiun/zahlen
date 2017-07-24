module Zahlen
  module ConektaGateway
    class CreatePlan
      def self.call(plan)
        if plan.amount_cents < 300
          raise 'Conekta minium subscription amount start at 3.00 MXN'
        end

        Conekta::Plan.create({
          id:                plan.gateway_reference_id,
          name:              plan.name,
          amount:            plan.amount_cents,
          currency:          plan.respond_to?(:amount_currency) ? plan.amount_currency : Zahlen.default_currency,
          interval:          plan.interval,
          frequency:         plan.frequency,
          trial_period_days: plan.respond_to?(:trial_period_days) ? plan.trial_period_days : nil,
          expiry_count:      plan.respond_to?(:expiry_count) ? plan.expiry_count : nil,
        })
      rescue Conekta::ErrorList
        return find_plan(plan)
      end

      def self.find_plan(plan)
        existing_plan = Conekta::Plan.find(plan.gateway_reference_id)
        unless existing_plan.blank?
          return existing_plan if validate_plan(plan, existing_plan)
          raise 'Conekta::Plan exist with same ID and it has differences'
        end
      rescue Conekta::ErrorList => error_list
        for error_detail in error_list.details do
          raise "Conketa Error Msg => #{error_detail.message}"
        end
      end

      def self.validate_plan(a, b)
        a.name            == b.name &&
        a.amount_cents    == b.amount &&
        a.amount_currency == b.currency &&
        a.interval        == b.interval &&
        a.frequency       == b.frequency
      end
    end
  end
end
