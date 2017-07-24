class CreateZahlenSubscription < ActiveRecord::Migration
  def change
    create_table :zahlen_subscriptions do |t|
      t.string :uuid
      t.string :plan_type
      t.integer :plan_id
      t.string :owner_type
      t.integer :owner_id
      t.string :account_type
      t.integer :account_id
      t.string :status
      t.integer :quantity
      t.datetime :start
      t.string :state
      t.integer :amount_cents
      t.string :amount_currency
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end
      t.datetime :ended_at
      t.datetime :trial_start
      t.datetime :trial_end
      t.datetime :virtual_trial_start
      t.datetime :virtual_trial_end
      t.datetime :canceled_at
      t.integer :payment_method
      t.string :gateway
      t.string :gateway_reference_id
      t.string :gateway_customer_id
      t.string :gateway_token_id
      t.string :gateway_status
      t.string :card_holdername
      t.string :card_last4
      t.string :card_brand
      t.string :card_bin
      t.date :card_expiration
      t.text :last_error
      t.string :coupon
      t.timestamps null: false
    end

    add_index :zahlen_subscriptions, [:uuid]
    add_index :zahlen_subscriptions, [:plan_id, :plan_type]
    add_index :zahlen_subscriptions, [:owner_id, :owner_type]
  end
end
