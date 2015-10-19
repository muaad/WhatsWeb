class Account < ActiveRecord::Base
	has_many :tickets
end
