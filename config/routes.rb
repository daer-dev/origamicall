Rails.application.routes.draw do
  post 'users/api_new' => 'users#api_new', as: :api_new_user
  post 'users/api_login' => 'users#api_login', as: :api_login_user
  post 'users/api_delete' => 'users#api_delete', as: :api_delete_user

  post 'services/api_new' => 'services#api_new', as: :api_new_service
  post 'services/api_delete' => 'services#api_delete', as: :api_delete_service

  mount Company::Engine, at: '/'
  mount Libs::Engine, at: '/libs'
  mount Ivr::Engine, at: '/ivr'
end