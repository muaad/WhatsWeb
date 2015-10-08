class FreshdeskIntegration
	def post body, url
		auth = {
			username: ENV['FRESHDESK_USER'],
			password: ENV['FRESHDESK_PASSWORD']
		}

		response = HTTParty.post(url, {
			body: body,
			basic_auth: auth,
			headers: { "Content-type" => "application/x-www-form-urlencoded" },
			debug_output: $stdout
		})		
	end

	def get url
		auth = {
			username: "muaad@sprout.co.ke",
			password: "freshbok24"
		}
		HTTParty.get(url, {basic_auth: auth})
	end

	def create_contact name, email
		post({"user[name]" => name, "user[email]" => email}, "http://muaad.freshdesk.com/contacts.json")
	end

	def create_ticket description, subject, email, cc_emails=""
		body = {
		  helpdesk_ticket: {
	      description: description,
	      subject: subject,
	      email: email,
	      priority: 1,
	      status: 2
		  },
		  cc_emails: cc_emails
		}
		post(body, "https://muaad.freshdesk.com/helpdesk/tickets.json")
		# `curl -u muaad@sprout.co.ke:freshbok24 -H "Content-Type: application/json" -d '{ "helpdesk_ticket": { "description": "Details about the issue...", "subject": "Support Needed...", "email": "mursal@outerspace.com", "priority": 1, "status": 2 }, "cc_emails": "mursal@freshdesk.com,mohaa@freshdesk.com" }' -X POST http://muaad.freshdesk.com/helpdesk/tickets.json`
	end

	def find_ticket id
		get("https://muaad.freshdesk.com/helpdesk/tickets/#{id}.json")
	end

	def add_comment ticket_id
		body = {
		  helpdesk_note: {
		    body:"Hi tom, Still Angry",
		    "private" => false
		  }
		}
		post(body, "https://muaad.freshdesk.com/helpdesk/tickets/#{ticket_id}/conversations/note.json")
	end

	def create_customer name, domains="", description
		body = {
			customer: {
			  name: name,
			  domains: domains,
			  description: description
			}
		}
		post(body, "https://muaad.freshdesk.com/customers.json")
	end

	def tickets
		get("https://muaad.freshdesk.com/helpdesk/tickets.json")
	end

	def create_user name, email="", description, mobile
		body = {
			user: {
			  name: name,
			  email: email,
			  mobile: mobile,
			  description: description
			}
		}
		post(body, "https://muaad.freshdesk.com/contacts.json")
	end
	
	# def create_user
	# 	`curl -u muaad@sprout.co.ke:freshbok24 -H "Content-Type: application/json" -X POST -d '{ "user": { "name":"Super Man", "email":"ram@freshdesk.com" }}' http://muaad.freshdesk.com/contacts.json`
	# end

	# def client
	# 	Freshdesk.new("https://muaad.freshdesk.com/", "muaad@sprout.co.ke", "freshbok24")
	# end

	# def create_user
	# 	client.post_users(:name => "test", :email => "test@143124test.com", :customer => "name")
	# end

	# def users
	# 	client.get_users
	# end
end