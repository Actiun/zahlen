class CreateZahlenCharge < ActiveRecord::Migration
  def change
    create_table :zahlen_charges do |t|
      t.string :uuid
      t.integer :status
      t.string :description
      t.string :payment_method
      t.integer :subscription_id
      t.string :gateway
      t.string :gateway_reference_id
      t.string :gateway_customer_id
      t.string :gateway_order_id
      t.string :gateway_card_id
      t.integer :amount_cents
      t.string :amount_currency
      t.string :card_holdername
      t.string :card_last4
      t.string :card_brand
      t.string :card_bin
      t.datetime :paid_at
      t.datetime :refunded_at
      t.datetime :failed_at
      t.integer :new_plan_id
      t.timestamps null: false
    end

    add_index :zahlen_charges, [:uuid]
    add_index :zahlen_charges, [:subscription_id]
    add_index :zahlen_charges, [:gateway_customer_id]
  end
end
