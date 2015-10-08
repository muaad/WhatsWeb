class Subscription < ActiveRecord::Base
  belongs_to :plan
  validates_presence_of :plan_id
  validates_presence_of :email
  
  attr_accessor :paypal_payment_token
  
  def save_with_payment
    response = paypal.make_recurring
    self.paypal_recurring_profile_token = response.profile_id
    save!
  end
  
  def paypal
    PaypalPayment.new(self)
  end

  def suspend
  	paypal.suspend
  end

  def reactivate
  	paypal.reactivate
  end

  def cancel
  	paypal.cancel
  end
  
  def payment_provided?
    paypal_payment_token.present?
  end
end
