class DeskIntegration
	# def self.client
	# 	Desk.configure do |config|
	# 	  config.support_email = "muadh24@gmail.com"
	# 	  config.subdomain = "mursal"
	# 	  config.consumer_key = "aj8SA0QxpknkwXY5Zdc6"
	# 	  config.consumer_secret = "GQCRm2EvfpovU0cR1KoBscQawK6HBU3DecQVzVq6"
	# 	  config.oauth_token = "SAxInDNrnRP49Abf5JWx"
	# 	  config.oauth_token_secret = "rUNoLvQEVCGPDoSx4UxreONLUPkyOVtpz8GVYgHR"
	# 	end
	# end

	def self.client
		DeskApi.configure do |config|
		  # basic authentication
		  config.username = 'muadh24@gmail.com'
		  # config.password = 'somepassword'

		  # oauth configuration
		  config.token           = 'SAxInDNrnRP49Abf5JWx'
		  config.token_secret    = 'rUNoLvQEVCGPDoSx4UxreONLUPkyOVtpz8GVYgHR'
		  config.consumer_key    = 'aj8SA0QxpknkwXY5Zdc6'
		  config.consumer_secret = 'GQCRm2EvfpovU0cR1KoBscQawK6HBU3DecQVzVq6'

		  config.endpoint = 'https://mursal.desk.com'
		end
	end

	def self.create_customer
		DeskApi.customers.create(
			{
			  first_name: "John",
			  last_name: "Doe",
			  emails: [
			    {
			      type: "work",
			      value: "john@acme.com"
			    },
			    {
			      type: "home",
			      value: "john@home.com"
			    }
			  ],
			  custom_fields: {
			    level: "vip"
			  }
			}
		)
	end

	def self.create_ticket
		DeskApi.cases.create(
		  :type => "phone",
		  :subject => "Creating a case via the API",
		  :priority => 4,
		  :status => "open",
		  :labels => [ "Spam", "Ignore" ],
		  :_links => {
		    :customer => {
		      :href => "/api/v2/customers/362409678",
		      :class => "customer"
		    },
		    :assigned_user => {
		      :href => "/api/v2/users/1",
		      :class => "user"
		    },
		    :assigned_group => {
		      :href => "/api/v2/groups/1",
		      :class => "group"
		    },
		    :locked_by => {
		      :href => "/api/v2/users/1",
		      :class => "user"
		    },
		    :entered_by => {
		      :href => "/api/v2/users/1",
		      :class => "user"
		    }
		  },
		  :message => {
		    :direction => "out",
		    :body => "Please assist me with this case",
		    # :to => "muadh24@gmail.com"
		  }
		)
	end
end