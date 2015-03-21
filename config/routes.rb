Rails.application.routes.draw do
  resources :photos

  post '/mailgun/webhook'

  get '/mailgun/webhook', to: 'mailgun#webhook', via: :post

  get '/about', to: 'about#index'

  root 'photos#index'
end
