class Branch < ActiveRecord::Base
	geocoded_by :address
	after_validation :geocode, :if => :address_changed?

	def self.find_nearest lat, long
		 Branch.near([lat, long], 20, :units => :km).first
	end
end
