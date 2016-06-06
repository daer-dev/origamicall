Libs::Engine.routes.draw do
  resources :accounts do
    member do
      get :delete
    end
  end

  resources :audios do
    member do
      get :delete
    end
  end

  resources :destinations do
    member do
      get :delete
    end
  end

  resources :grammars do
    member do
      get :delete
      get :export
    end
  end

  resources :lists do
    member do
      get :delete
    end
  end

  resources :schedules do
    member do
      get :delete
    end
  end

  resources :tables do
    member do
      get :delete
    end
  end

  root :to => 'layouts#index'
end