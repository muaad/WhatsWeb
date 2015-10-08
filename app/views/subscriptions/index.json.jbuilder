json.array!(@subscriptions) do |subscription|
  json.extract! subscription, :id, :plan_id, :email, :paypal_customer_token, :paypal_recurring_profile_token
  json.url subscription_url(subscription, format: :json)
end
