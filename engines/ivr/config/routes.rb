Ivr::Engine.routes.draw do
  resources :trees do
    member do
      get :delete
      get :export
    end

    resources :nodes do
      member do
        get :delete
        get :disable
      end
    end
  end

  post 'voicemail_nodes/send_audio' => 'voicemail_nodes#send_audio', as: :send_audio_voicemail_nodes
  get 'vm/:token' => 'voicemail_nodes#download_audio', as: :download_audio_voicemail_nodes

  mount Libs::Engine, at: '/libs'

  root :to => 'layouts#index'
end