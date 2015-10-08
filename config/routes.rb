Rails.application.routes.draw do
  resources :subscriptions

  resources :plans

  resources :branches
  get 'paypal/checkout', to: 'subscriptions#paypal_checkout'
  match 'subscriptions/:id/suspend', to: 'subscriptions#suspend', as: 'suspend_subscription', via: "post"
  match 'subscriptions/:id/reactivate', to: 'subscriptions#reactivate', as: 'reactivate_subscription', via: "post"
  match 'subscriptions/:id/cancel', to: 'subscriptions#cancel', as: 'cancel_subscription', via: "post"
  match 'subscriptions/ipn', to: 'subscriptions#ipn', as: 'ipn', via: "post"

  root to: 'visitors#index'
  devise_for :users

  post "outbound" => "zendesk#outbound"
  post "inbound" => "zendesk#inbound"
  post "notifications" => "desk#notifications"
  get "support" => "desk#support"
  get "oauth" => "zendesk#oauth"
  get "welcome_back" => "zendesk#welcome_back"

  post "send_location" => "branches#send_location"
end
