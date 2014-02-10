Nsiaf::Application.routes.draw do
  resources :versions, only: [:index]

  resources :assets

  resources :auxiliaries do
    get :change_status, on: :member
  end

  resources :accounts

  resources :departments do
    get :change_status, on: :member
  end

  resources :buildings do
    get :change_status, on: :member
  end

  resources :entities

  resources :users do
    get :change_status, on: :member
  end

  post '/dbf/:model/import', to: 'dbf#import', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'import_dbf'
  get '/dbf/:model', to: 'dbf#index', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'dbf'
  get '/dbf', to: redirect('/dbf/buildings'), as: 'migration'

  devise_for :users, controllers: { sessions: "sessions" }, skip: [ :sessions ]
  as :user do
    get '/login' => 'sessions#new', as: :new_user_session
    post '/login' => 'sessions#create', as: :user_session
    delete '/logout' => 'sessions#destroy', as: :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#index'
end
