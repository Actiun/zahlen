Zahlen::Engine.routes.draw do
  get   '/subscription/:uuid/status', to: 'subscriptions#status',      as: :zahlen_subscription_status
  get   '/subscription/:uuid',        to: 'subscriptions#show',        as: :zahlen_subscription
  post  '/change_plan/:uuid'          to: 'subscriptions#change_plan', as: :zahlen_change_subscription_plan

  mount ConektaEvent::Engine => '/webooks/'
end
