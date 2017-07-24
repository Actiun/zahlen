class CreateZahlenGatewayWebhooks < ActiveRecord::Migration
  def change
    create_table :zahlen_gateway_webhooks do |t|
      t.string :gateway
      t.string :gateway_reference_id
      t.timestamps null: false
    end
    add_index :zahlen_gateway_webhooks, [:gateway_reference_id, :gateway],
      name: 'index_zahlen_gateway_webhooks'
  end
end
