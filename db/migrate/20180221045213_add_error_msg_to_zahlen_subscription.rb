class AddErrorMsgToZahlenSubscription < ActiveRecord::Migration
  def change
    add_column :zahlen_subscriptions, :error_msg, :string
  end
end
