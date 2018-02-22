class RemoveStatusFromSubscription < ActiveRecord::Migration
  def change
    remove_column :zahlen_subscriptions, :status
  end
end
