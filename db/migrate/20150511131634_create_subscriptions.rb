class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :plan, index: true
      t.string :email
      t.string :paypal_customer_token
      t.string :paypal_recurring_profile_token

      t.timestamps
    end
  end
end
