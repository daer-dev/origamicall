Company::Engine.routes.draw do
  root :to => 'home#index'

  match '/' => 'home#index', :via => :post
end