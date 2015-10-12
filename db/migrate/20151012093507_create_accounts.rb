class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :ongair_phone_number
      t.string :ongair_token
      t.string :freshdesk_url
      t.string :freshdesk_api_key

      t.timestamps
    end
  end
end
