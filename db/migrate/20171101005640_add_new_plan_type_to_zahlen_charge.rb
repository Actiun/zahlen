class AddNewPlanTypeToZahlenCharge < ActiveRecord::Migration
  def change
    add_column :zahlen_charges, :new_plan_type, :string
  end
end
