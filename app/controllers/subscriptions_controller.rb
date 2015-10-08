class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :suspend, :reactivate, :cancel]

  respond_to :html

  def new
    plan = Plan.find(params[:plan_id])
    @subscription = plan.subscriptions.build
    if params[:PayerID]
      @subscription.paypal_customer_token = params[:PayerID]
      @subscription.paypal_payment_token = params[:token]
      @subscription.email = @subscription.paypal.checkout_details.email
    end
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save_with_payment
      redirect_to @subscription, :notice => "Thank you for subscribing!"
    else
      render :new
    end
  end

  def show
  end

  def ipn
    puts params
    render json: {status: "Received"}
  end

  def suspend
    @subscription.suspend
    redirect_to @subscription, :notice => "Subscription has been suspended"
  end

  def reactivate
    @subscription.reactivate
    redirect_to @subscription, :notice => "Subscription has been reactivated"
  end

  def cancel
    @subscription.cancel
    redirect_to @subscription, :notice => "Subscription has been canceled"
  end
  
  def paypal_checkout
    plan = Plan.find(params[:plan_id])
    subscription = plan.subscriptions.build
    redirect_to subscription.paypal.checkout_url(
      return_url: "https://www.paypal.com/checkoutnow/",
      # ipn_url: "http://60cc11ec.ngrok.com#{ipn_path}",
      cancel_url: root_url
    )
  end

  private
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def subscription_params
      params.require(:subscription).permit(:plan_id, :email, :paypal_customer_token, :paypal_recurring_profile_token, :paypal_payment_token)
    end
end
