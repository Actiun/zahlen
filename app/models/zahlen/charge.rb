module Zahlen
  # A transaction is automatically generated every time Zahlen makes a payment
  # related operation on an subcription or charge such as a successful charge,
  # failure, authorization or refund.
  class Charge < ActiveRecord::Base
    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================
    include Zahlen::Uuider
    include AASM

    # == Relationships ========================================================
    belongs_to :new_plan, polymorphic: true
    belongs_to :subscription

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================
    self.inheritance_column = nil

    # == Instance Methods =====================================================
    enum payment_method: {
      card:           1,
      paypal:         2,
      cash:           3,
      check:          4,
      wire_transfer:  5
    }

    enum status: {
      pending_payment: 0,
      payed:           1,
      refunded:        2,
      failed:          3
    }

    aasm column: 'status', enum: true do
      state :pending_payment, initial: true
      state :payed
      state :refunded
      state :failed

      event :paid, after: :process_charge do
        transitions from: :pending_payment, to: :payed
      end

      event :refund, after: :process_refund do
        transitions from: :payed, to: :refunded
      end

      event :fail, after: :process_fail do
        transitions from: [:pending_payment, :payed], to: :failed
      end
    end

    def uuid_prefix
      'chrg_'
    end

    def process_charge
      Zahlen::ChargePaid.call(nil, self)
    end

    def process_refund
      update_columns(refunded_at: Time.zone.now) if refunded_at.blank?
    end

    def process_fail
    end
  end
end
