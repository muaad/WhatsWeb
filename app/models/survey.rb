class Survey < ActiveRecord::Base
  belongs_to :customer
  belongs_to :ticket
  belongs_to :account
end
