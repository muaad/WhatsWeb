require 'zendesk_api'
require 'httparty'

class ZendeskIntegration
	def client
		client = ZendeskAPI::Client.new do |config|
		  # Mandatory:

		  config.url = "https://muaad.zendesk.com/api/v2" # e.g. https://mydesk.zendesk.com/api/v2

		  # Basic / Token Authentication
		  config.username = ENV['ZENDESK_USER']

		  # Choose one of the following depending on your authentication choice
		  # config.token = "your zendesk token"
		  config.password = ENV['ZENDESK_PASSWORD']

		  # OAuth Authentication
		  # config.access_token = "your OAuth access token"

		  # Optional:

		  # Retry uses middleware to notify the user
		  # when hitting the rate limit, sleep automatically,
		  # then retry the request.
		  config.retry = true

		  # Logger prints to STDERR by default, to e.g. print to stdout:
		  require 'logger'
		  config.logger = Logger.new(STDOUT)

		  # Changes Faraday adapter
		  # config.adapter = :patron

		  # Merged with the default client options hash
		  # config.client_options = { :ssl => false }

		  # When getting the error 'hostname does not match the server certificate'
		  # use the API at https://yoursubdomain.zendesk.com/api/v2
		end
	end

	def create_ticket subject, comment, submitter_id, priority, custom_fields
		ZendeskAPI::Ticket.create(client, :subject => subject, :comment => { :value => comment }, :submitter_id => submitter_id, :priority => priority, :custom_fields => custom_fields)
	end

	def find_ticket id
		client.tickets.find(client, :id => id)
	end

	def find_tickets_by_phone_number_and_status phone_number, status
		tickets = []
		client.tickets.all do |ticket|
			if ticket["custom_fields"][0].value == phone_number && ticket.status == status
				tickets << ticket
			end
		end
		tickets
	end

	def forward_ticket_updates phone_number, message
		HTTParty.post("http://beta.ongair.im/api/v1/base/send?token=#{ENV['ONGAIR_API_KEY']}", body: {phone_number: phone_number, text: message})
	end
end