Rails.application.routes.draw do
  resources :branches

  root to: 'visitors#index'
  devise_for :users

  post "outbound" => "zendesk#outbound"
  post "inbound" => "zendesk#inbound"
end
