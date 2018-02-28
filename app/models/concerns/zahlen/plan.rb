require 'active_support/concern'

module Zahlen
  module Plan
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true
      validates :amount_cents, presence: true
      validates :amount_currency, presence: true
      validates :frequency, presence: true
      validates :interval, presence: true
      validates :gateway_reference_id, presence: true
      validates :gateway_reference_id, uniqueness: true

      before_validation :create_gateway_plan

      has_many :subscriptions, class_name: 'Zahlen::Subscription'

      Zahlen.register_subscribable(self)
    end

    def create_gateway_plan
      return unless gateway_reference_id.blank?
      gateway_plan = Zahlen::CreatePlan.call(self)
      self.gateway_reference_id ||= gateway_plan['id']
    end

    def plan_class
      self.class.plan_class
    end

    def price_cents
      amount_cents
    end

    def currency
      amount_currency
    end

    module ClassMethods
      def subscribable?
        true
      end

      def plan_class
        self.to_s.underscore
      end
    end
  end
end
