class Ticket < ActiveRecord::Base
	belongs_to :customer
	belongs_to :account
	scope :not_closed, -> {  where("status = ? or status = ? or status = ? or status = ?", "1", "2", "3", "4") }

	STATUS_NEW = '1'
	STATUS_OPEN = '2'
	STATUS_PENDING = '3'
	STATUS_SOLVED = '4'
	STATUS_CLOSED = '5'
	STATUS_WAITING_ON_CUSTOMER = '6'
	STATUS_WAITING_ON_THIRD_PARTY = '7'

	def self.unsolved_tickets account, phone_number
		Ticket.not_closed.where("account_id = ? and phone_number = ?", account.id, phone_number)
	end

	def self.status_map
		status_new = {STATUS_NEW => ["new", "nuevo", "novo", "nieuw", "neu"]}
		status_open = {STATUS_OPEN => ["open", "abierto", "aberto", "offen"]}
		status_pending = {STATUS_PENDING => ["pending", "pendiente", "in afwachting", "pendente", "wartend"]}
		status_waiting_on_customer = {STATUS_WAITING_ON_CUSTOMER => ["waiting on customer", "angehalten"]}
		status_waiting_on_third_party = {STATUS_WAITING_ON_THIRD_PARTY => ["waiting on third party"]}
		status_solved = {STATUS_SOLVED => ["resolved", "resuelto", "resolvido", "opgelost", "gelöst"]}
		status_closed = {STATUS_CLOSED => ["closed", "cerrado", "geschlossen", "fechado"]}
		status_dictionary = {status_new: status_new, status_open: status_open, status_pending: status_pending, status_solved: status_solved, status_closed: status_closed, status_waiting_on_customer: status_waiting_on_customer, status_waiting_on_third_party: status_waiting_on_third_party}
	end

	def self.get_status status
		status = status.downcase
		statuses = self.status_map
		statuses.values.each do |s|
			status = s.keys.first if s.values.first.include?(status)
		end
		status
	end
end
