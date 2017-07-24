Zahlen::Engine.routes.draw do
  get '/subscription/:uuid/status', to: 'subscriptions#status',   as: :zahlen_subscription_status
  get '/subscription/:uuid',        to: 'subscriptions#show',     as: :zahlen_subscription

  mount ConektaEvent::Engine => '/webooks/'
end
