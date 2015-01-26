require "zendesk_integration"
class ZendeskController < ApplicationController
	skip_before_action :verify_authenticity_token
	def inbound
		zendesk = ZendeskIntegration.new
		phone_number = zendesk.find_ticket(params[:ticket].to_i)["custom_fields"][0].value
		zendesk.forward_ticket_updates phone_number, params[:comment]
		render json: {status: "recieved"}
	end

	def outbound
		zendesk = ZendeskIntegration.new
		client = zendesk.client
		tickets = zendesk.find_tickets_by_phone_number_and_status params[:phone_number], "open"
		if tickets.size == 0
			zendesk.create_ticket "WhatsApp Ticket", params[:text], client.current_user.id, "Urgent", [{"id"=>25609801, "value"=>params[:phone_number]}]
		else
			ticket = tickets.last
			ticket.comment = { :value => params[:text], :author_id => client.current_user.id, public: false }
			ticket.save!
		end

		render json: {status: "sent"}
	end
end