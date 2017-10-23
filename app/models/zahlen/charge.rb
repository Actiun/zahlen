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
    after_update :active_subscription

    # == Class Methods ========================================================
    self.inheritance_column = nil

    # == Instance Methods =====================================================
    enum status: { pending_payment: 0, paid: 1, refunded: 2, failed: 3 }

    def uuid_prefix
      'chrg_'
    end

    def active_subscription
      return unless status_changed?
      sub = subscription
      if status == 'paid'
        current_time = Time.zone.now
        sub.update_attributes(
          current_period_start: current_time,
          current_period_end: current_time + 1.month
        )
        sub.activate! if sub.pending_payment?
      elsif status == 'failed'
        sub.fail! if sub.pending_payment?
      end
    end
  end
end
