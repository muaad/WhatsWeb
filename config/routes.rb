Rails.application.routes.draw do
  resources :branches

  root to: 'visitors#index'
  devise_for :users

  post "outbound" => "zendesk#outbound"
  post "inbound" => "zendesk#inbound"

  post "send_location" => "branches#send_location"
end
