class AddAccountToTicket < ActiveRecord::Migration
  def change
    add_reference :tickets, :account, index: true
  end
end
