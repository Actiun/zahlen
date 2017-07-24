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
    belongs_to :subscription

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Class Methods ========================================================
    self.inheritance_column = nil

    # == Instance Methods =====================================================
    enum status: { pending_payment: 0, paid: 1, refunded: 2, failed: 3 }

    def uuid_prefix
      'chrg_'
    end
  end
end