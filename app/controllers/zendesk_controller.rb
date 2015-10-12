require "zendesk_integration"
require "freshdesk_integration"
require 'oauth2'
class ZendeskController < ApplicationController
	skip_before_action :verify_authenticity_token

	def send_message phone_number, message, account
		HTTParty.post("https://app.ongair.im/api/v1/base/send?token=#{account.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
	end

	def oauth_client
		client = OAuth2::Client.new('muaad',
		  '590d1854ee07bb434a36dab3dd0d54c8bcd7b183357753bcc17407cfbff1cfe3',
		  site: 'https://mucaad.zendesk.com',
		  token_url: "/oauth/tokens",
		  authorize_url: "/oauth/authorizations/new")
	end

	def strip_html(str)
	  document = Nokogiri::HTML.parse(str)
	  document.css("br").each { |node| node.replace("\n") }
	  document.text
	end

	def inbound
		# zendesk = ZendeskIntegration.new
		# phone_number = zendesk.find_ticket(params[:ticket].to_i)["custom_fields"][0].value
		# zendesk.forward_ticket_updates phone_number, params[:comment]
		ticket_id = params[:freshdesk_webhook][:ticket_id]
		comment = strip_html(params[:freshdesk_webhook][:ticket_latest_public_comment])
		phone_number = Ticket.find_by(ticket_id: ticket_id).phone_number
		account = Account.find_by ongair_phone_number: params[:account]

		send_message phone_number, comment, account

		render json: {status: "recieved"}
		# fresh = FreshdeskIntegration.new
		# render json: {status: "recieved"}
	end

	def status_change
		ticket_id = params[:freshdesk_webhook][:ticket_id]
		status = params[:freshdesk_webhook][:ticket_status]
		ticket = Ticket.find_by(ticket_id: ticket_id)
		ticket.update(status: Ticket.get_status(status))

		render json: { status: status}
	end

	def new_ticket description, subject, customer, account
		fresh = FreshdeskIntegration.new
		ticket = fresh.create_ticket description, "#{subject}##{customer.phone_number}", customer.email, account
		ticket_id = ticket['helpdesk_ticket']['display_id']
		Ticket.create! phone_number: customer.phone_number, customer: customer, ticket_id: ticket_id, status: ticket['helpdesk_ticket']['status'], account: account
		send_message params[:phone_number], "Hi #{customer.name},\nThanks for getting in touch with us. Your reference ID is ##{ticket_id}. We will get back to you shortly.", account
		{ message: "New ticket created", ticket: ticket }
	end

	def freshdesk
		fresh = FreshdeskIntegration.new
		account = Account.find_by ongair_phone_number: params[:account]
		tickets = Ticket.unsolved_tickets account, params[:phone_number]
		customer = Customer.find_or_create_by! phone_number: params[:phone_number]
		customer.update name: params[:name]
		customer.update email: "#{fresh.random_string}@#{fresh.random_string}.com" if customer.email.blank?

		if tickets.blank?
			puts "\n\n>>>>>> No tickets found\n\n"
			response = new_ticket params[:text], "WhatsApp Ticket", customer, account
		else
			puts "\n\n>>>>>> Found a ticket\n\n"
			ticket_id = tickets.last.ticket_id
			ticket = fresh.find_ticket ticket_id, account
			user_id = ticket['helpdesk_ticket']['requester_id']
			if !ticket.blank?
				if params[:notification_type] == "MessageReceived"
					t = fresh.add_note ticket_id, params[:text], user_id, account
				elsif params[:notification_type] == "ImageReceived"
					t = fresh.add_note ticket_id, "Image Received", user_id, account, params[:image]
				end
				response = { message: "Comment added", ticket: t }
			else
				response = new_ticket params[:text], "WhatsApp Ticket", customer, account
			end
		end
		render json: response
	end

	def outbound
		zendesk = ZendeskIntegration.new
		client = zendesk.client
		tickets = zendesk.find_tickets_by_phone_number_and_status params[:phone_number], "open"
		user = zendesk.create_user(params[:name], params[:phone_number])
		if tickets.size == 0
			zendesk.create_ticket "WhatsApp Ticket", params[:text], user.id, user.id, "Urgent", [{"id"=>25609801, "value"=>params[:phone_number]}]
		else
			ticket = tickets.last
			ticket.comment = { :value => params[:text], :author_id => user.id, public: false }
			ticket.save!
		end

		render json: {status: "sent"}
		# fresh = FreshdeskIntegration.new
		# fresh.create_user params[:name], "A WhatsApp user", params[:phone_number].to_i
		# fresh.create_ticket params[:text], "WhatsApp Ticket", "nano@sprout.co.ke"

		# render json: {status: "sent"}
	end

	def oauth
		auth_url = oauth_client.auth_code.authorize_url(:redirect_uri => 'https://2e64aa8.ngrok.com/welcome_back', scope: "read write")
		redirect_to auth_url
	end

	def welcome_back
		puts "Code >>>>>>>>>> #{params[:code]}"
		token = oauth_client.auth_code.get_token(params[:code], :redirect_uri => 'https://2e64aa8.ngrok.com/welcome_back')
		puts "Token >>>>>>>>>> #{token.token}"
		puts "URL >>>>>>>>>> #{token.client.site}/api/v2"
		# token = client.auth_code.get_token(params[:code], :redirect_uri => 'https://2e64aa8.ngrok.com/welcome_back')
		# client = ZendeskAPI::Client.new do |c|
		#   c.access_token = token.token
		#   c.url = "#{token.client.site}/api/v2"

		#   require 'logger'
		#   c.logger = Logger.new(STDOUT)
		# end
		# puts "Token >>>>>>>>>> #{token}"
		# puts client.current_user
	end
	# 2fadaf74c44f09ecb49e73cce4e3d886cf93ee2f9b323591dc97b802ee3d5a20
	# 590d1854ee07bb434a36dab3dd0d54c8bcd7b183357753bcc17407cfbff1cfe3
end