require 'aasm'

module Zahlen
  class Subscription < ActiveRecord::Base
    # == Constants ============================================================

    # == Attributes ===========================================================
    attr_accessor :old_plan

    # == Extensions ===========================================================
    include Zahlen::Uuider
    include AASM

    # == Relationships ========================================================
    has_many :charges, class_name: 'Zahlen::Charge'

    belongs_to :plan,  polymorphic: true
    belongs_to :owner, polymorphic: true
    belongs_to :account, polymorphic: true

    # == Validations ==========================================================
    validates :plan_id, presence: true
    validates :plan_type, presence: true
    validates :amount_cents, presence: true
    validates :amount_currency, presence: true

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================

    # == Instance Methods =====================================================
    enum payment_method: {
      card:           1,
      paypal:         2,
      cash:           3,
      check:          4,
      wire_transfer:  5
    }

    aasm column: 'state', skip_validation_on_save: true do
      state :pending, initial: true
      state :processing
      state :pending_payment
      state :active
      state :canceled
      state :errored

      event :process, after: :start_subscription do
        transitions from: :pending, to: :processing
      end

      event :activate, after: :instrument_activate do
        transitions from: [:processing, :pending_payment], to: :active
      end

      event :waiting, after: :instrument_waiting do
        transitions from: :processing, to: :pending_payment
      end

      event :cancel, after: :instrument_canceled do
        transitions from: :active, to: :canceled
      end

      event :fail, after: :instrument_fail do
        transitions from: [:pending, :processing], to: :errored
      end

      event :refund, after: :instrument_refund do
        transitions from: :finished, to: :refunded
      end
    end

    def name
      plan.name
    end

    def price
      plan.amount
    end

    def redirector
      plan
    end

    def offline?
      return false if payment_method.blank?
      %w[cash check wire_transfer].include?(payment_method)
    end

    def sync_gateway
      case gateway
      when 'conekta'
        Zahlen::ConektaGateway::SyncSubscription.call(self)
      end
    end

    def to_param
      uuid
    end

    def instrument_plan_changed(old_plan)
      self.old_plan = old_plan
      Zahlen.instrument(instrument_key('plan_changed'), self)
      Zahlen.instrument(instrument_key('plan_changed', false), self)
    end

    def redirector
      plan
    end

    def uuid_prefix
      'sub_'
    end

    def manual_period(start_at, end_at = nil)
      update_attributes(
        current_period_start: start_at,
        current_period_end: end_at.blank? ? (start_at + 1.month) : end_at
      )
    end

    # private

    def start_subscription
      Zahlen::StartSubscription.call(self)
    end

    def instrument_activate
      Zahlen.instrument(instrument_key('active'), self)
      Zahlen.instrument(instrument_key('active', false), self)
    end

    def instrument_waiting
      create_charge('pending_payment')
      Zahlen.instrument(instrument_key('waiting_payment'), self)
      Zahlen.instrument(instrument_key('waiting_payment', false), self)
    end

    def instrument_canceled
      Zahlen.instrument(instrument_key('canceled'), self)
      Zahlen.instrument(instrument_key('canceled', false), self)
    end

    def instrument_fail
      create_charge('failed') if payment_method == 'card'
      Zahlen.instrument(instrument_key('failed'), self)
      Zahlen.instrument(instrument_key('failed', false), self)
    end

    def instrument_refund
      create_charge('refunded')
      Zahlen.instrument(instrument_key('refunded'), self)
      Zahlen.instrument(instrument_key('refunded', false), self)
    end

    def instrument_key(instrument_type, include_class = true)
      if include_class
        "zahlen.#{plan_type}.subscription.#{instrument_type}"
      else
        "zahlen.subscription.#{instrument_type}"
      end
    end

    def create_charge(status, payment_method = nil, new_plan = nil)
      Zahlen::Charge.create(
        status: status,
        subscription_id: id,
        payment_method: payment_method || self.payment_method,
        new_plan: new_plan || plan,
        description: new_plan.try(:name) || plan.name,
        amount_cents: new_plan.try(:amount_cents) || amount_cents,
        amount_currency: new_plan.try(:amount_currency) || amount_currency,
        gateway_customer_id: gateway_customer_id,
        card_last4: card_last4
      )
    end
  end
end
