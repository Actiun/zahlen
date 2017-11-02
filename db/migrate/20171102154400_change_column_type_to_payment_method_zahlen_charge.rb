class ChangeColumnTypeToPaymentMethodZahlenCharge < ActiveRecord::Migration
  def change
    pms = Zahlen::Charge.payment_methods
    Zahlen::Charge.select("*, payment_method as old_pm").find_each do |c|
      next if c.old_pm.blank?
      new_pm = pms[c.old_pm]
      c.update_column(:payment_method, new_pm)
    end

    change_column :zahlen_charges, :payment_method, 'integer USING CAST(payment_method AS integer)'
  end
end
