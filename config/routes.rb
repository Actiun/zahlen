Zahlen::Engine.routes.draw do
  get   '/subscription/:uuid/status', to: 'subscriptions#status',      as: :subscription_status
  get   '/subscription/:uuid',        to: 'subscriptions#show',        as: :subscription
  post  '/change_plan/:uuid',         to: 'subscriptions#change_plan', as: :change_subscription_plan
  post  '/update_card/:uuid',         to: 'subscriptions#update_card', as: :update_subscription_card

  mount ConektaEvent::Engine => '/webooks/'
end
