require "zendesk_integration"
require "freshdesk_integration"
require 'oauth2'
class ZendeskController < ApplicationController
	skip_before_action :verify_authenticity_token
	def oauth_client
		client = OAuth2::Client.new('muaad',
		  '590d1854ee07bb434a36dab3dd0d54c8bcd7b183357753bcc17407cfbff1cfe3',
		  site: 'https://mucaad.zendesk.com',
		  token_url: "/oauth/tokens",
		  authorize_url: "/oauth/authorizations/new")
	end
	def inbound
		zendesk = ZendeskIntegration.new
		phone_number = zendesk.find_ticket(params[:ticket].to_i)["custom_fields"][0].value
		zendesk.forward_ticket_updates phone_number, params[:comment]
		render json: {status: "recieved"}
		# fresh = FreshdeskIntegration.new
		# render json: {status: "recieved"}
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