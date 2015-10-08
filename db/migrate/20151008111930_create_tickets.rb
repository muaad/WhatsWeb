class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :phone_number
      t.string :ticket_id
      t.string :status

      t.timestamps
    end
  end
end
