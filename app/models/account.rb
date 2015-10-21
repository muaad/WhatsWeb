class Account < ActiveRecord::Base
	has_many :tickets
	has_many :surveys
end
