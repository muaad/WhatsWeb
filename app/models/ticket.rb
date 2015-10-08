class Ticket < ActiveRecord::Base
	scope :not_closed, -> {  where("status = ? or status = ? or status = ? or status = ?", "1", "2", "3", "4") }
end
