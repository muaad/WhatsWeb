class FreshdeskIntegration
	def post body, url, account
		auth = {
			username: account.freshdesk_api_key,
			password: "skbvjbjkbkjb"
		}

		response = HTTParty.post(url, {
			body: body,
			basic_auth: auth,
			headers: { "Content-type" => "application/x-www-form-urlencoded" },
			debug_output: $stdout
		})		
	end

	def post_multiparty body, url, account
		auth = {
			username: account.freshdesk_api_key,
			password: "skbvjbjkbkjb"
		}

		response = HTTMultiParty.post(url, {
			body: body,
			basic_auth: auth,
			headers: { "Content-type" => "application/x-www-form-urlencoded" },
			debug_output: $stdout
		})
	end

	def get url, account
		auth = {
			username: account.freshdesk_api_key,
			password: "skbvjbjkbkjb"
		}
		HTTParty.get(url, {basic_auth: auth})
	end

	def create_survey ticket_id, account, rating="", feedback=""
		post({feedback: feedback}, "#{account.freshdesk_url}/helpdesk/tickets/#{ticket_id}/surveys/rate.json?rating=#{rating}", account)
	end

	def create_contact name, email, account
		post({"user[name]" => name, "user[email]" => email}, "#{account.freshdesk_url}/contacts.json", account)
	end

	def random_string
	  cs = [*'0'..'9', *'a'..'z', *'a'..'z']-['O']-['I']-['1']-['0']-['i']-['o']
	  5.times.map { cs.sample }.join.downcase
	end

	def create_ticket description, subject, email, account, tags=[]
		body = {
		  helpdesk_ticket: {
		      description: description,
		      subject: subject,
		      email: email,
		      priority: 1,
		      status: 1
		  }
		}
		tags_query = tags.blank? ? "" : "?helpdesk[tags]=#{tags.join(",")}"
		post(body, "#{account.freshdesk_url}/helpdesk/tickets.json#{tags_query}", account)
		# `curl -u muaad@sprout.co.ke:freshbok24 -H "Content-Type: application/json" -d '{ "helpdesk_ticket": { "description": "Details about the issue...", "subject": "Support Needed...", "email": "mursal@outerspace.com", "priority": 1, "status": 2 }, "cc_emails": "mursal@freshdesk.com,mohaa@freshdesk.com" }' -X POST http://muaad.freshdesk.com/helpdesk/tickets.json`
	end

	def find_ticket id, account
		get("#{account.freshdesk_url}/helpdesk/tickets/#{id}.json", account)
	end
	

	def add_note ticket_id, note, user_id, account, attachment=""
		body = {
		  helpdesk_note: {
		    body: note,
		    "private" => false,
		    incoming: true,
		    user_id: user_id
		  }
		}

		if !attachment.blank?
			site = RestClient::Resource.new("#{account.freshdesk_url}/helpdesk/tickets/#{ticket_id}/conversations/note.json", account.freshdesk_api_key, "test")
			temp = {body: note, 'private'=>false, incoming: true, user_id: user_id, attachments: {''=>[{resource: File.new(attachment, 'rb')}]}}
			site.post({helpdesk_note: temp}, content_type: "application/json")
		else
			post(body, "#{account.freshdesk_url}/helpdesk/tickets/#{ticket_id}/conversations/note.json", account)
		end
	end

	def create_customer name, domains="", description, account
		body = {
			customer: {
			  name: name,
			  domains: domains,
			  description: description
			}
		}
		post(body, "#{account.freshdesk_url}/customers.json", account)
	end

	def tickets account
		get("#{account.freshdesk_url}/helpdesk/tickets.json", account)
	end

	def find_user_by_phone_number phone_number, account
		get("#{account.freshdesk_url}/helpdesk/contacts.json?query=#{phone_number}", account)
	end

	def create_user name, email="", description, phone_number, account
		body = {
			user: {
			  name: name,
			  email: email,
			  mobile: phone_number,
			  description: description
			}
		}
		post(body, "#{account.freshdesk_url}/contacts.json", account)
	end

	def find_or_create_user name, email="", description, phone_number, account
		user = find_user_by_phone_number phone_number, account
		if user.blank?
			user = create_user name, email, description, phone_number, account
		end
		user
	end

	# def create_user
	# 	`curl -u muaad@sprout.co.ke:freshbok24 -H "Content-Type: application/json" -X POST -d '{ "user": { "name":"Super Man", "email":"ram@freshdesk.com" }}' http://muaad.freshdesk.com/contacts.json`
	# end

	def client account
		Freshdesk.new(account.freshdesk_url, account.freshdesk_api_key, "X")
	end

	# def create_user
	# 	client.post_users(:name => "test", :email => "test@143124test.com", :customer => "name")
	# end

	# def users
	# 	client.get_users
	# end
end