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

	def create_ticket subject, comment, submitter_id, requester_id, priority, custom_fields
		ZendeskAPI::Ticket.create(client, :subject => subject, :comment => { :value => comment }, :submitter_id => submitter_id,
		 :requester_id => requester_id, :priority => priority, :custom_fields => custom_fields)
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
		HTTParty.post("http://beta.ongair.im/api/v1/base/send?token=#{ENV['ONGAIR_API_KEY']}", body: {phone_number: phone_number, text: message, thread: true})
	end

	def find_user_by_phone_number phone_number
		client.users.all do |user|
			return user if user.phone == phone_number
		end
	end

	def find_ticket_field title
	  field = nil
	  client.ticket_fields.all do |ticket_field|
	    if ticket_field["title"] == title
	      field = ticket_field
	    end
	  end
	  field
	end

	def create_user name, phone_number
		if find_user_by_phone_number(phone_number).nil?
			user = ZendeskAPI::User.create(client, { name: name, phone: phone_number })
		else
			user = find_user_by_phone_number(phone_number)
		end
		user
	end

	def create_trigger title, conditions={}, actions=[]
		ZendeskAPI::Trigger.create(client, {title: title, conditions: conditions, actions: actions})
		# actions = [{field: "notification_target", value: ["20092202", "Ticket {{ticket.id}} has been updated."]}] # Use target as action
		# ZendeskAPI::Trigger.create(z.client, {title: "Trigger from web API", conditions: {all: [{field: "status", operator: "is", value: "open"}]}, actions: [{field: "status", value: "solved"}]})
	end

	def create_target title, target_url, attribute, method
		ZendeskAPI::Target.create(client, {type: "url_target", title: title, target_url: target_url, attribute: attribute, method: method})		
	end
end