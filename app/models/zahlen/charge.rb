module Zahlen
  # A transaction is automatically generated every time Zahlen makes a payment
  # related operation on an subcription or charge such as a successful charge,
  # failure, authorization or refund.
  class Charge < ActiveRecord::Base
    # == Constants ============================================================

    # == Attributes ===========================================================

    # == Extensions ===========================================================
    include Zahlen::Uuider

    # == Relationships ========================================================
    belongs_to :new_plan, polymorphic: true
    belongs_to :subscription

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================
    after_update :process_charge

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
      paid:            1,
      refunded:        2,
      failed:          3
    }

    def uuid_prefix
      'chrg_'
    end

    def process_charge
      Zahlen::ChargePaid.call(nil, self) if status_changed? && paid?
    end
  end
end
