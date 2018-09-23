Rails.application.routes.draw do
  get 'bugs/count', to: 'bugs#count'
  get 'bugs/:number', to: 'bugs#show'
  resources :bugs, only: [ :create ]
end
