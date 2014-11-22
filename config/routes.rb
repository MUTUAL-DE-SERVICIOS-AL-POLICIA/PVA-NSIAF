Nsiaf::Application.routes.draw do
  resources :note_entries, only: [:index, :show, :new, :create] do
    get :get_suppliers, on: :collection
  end

  resources :kardex_prices

  resources :kardexes

  resources :derecognised, only: :index

  resources :requests, except: [:edit, :destroy] do
    get :search_subarticles, on: :collection
  end

  resources :materials, except: [:destroy] do
    post :change_status, on: :member
    get :reports, on: :collection
  end

  resources :articles, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :subarticles, except: [:destroy] do
    resources :kardexes
    member do
      post :change_status
      get :verify_amount
      get :kardex
    end
    collection do
      get :articles
      get :get_subarticles
      get :recode
      get :autocomplete
      get :subarticles_array
    end
  end

  resources :barcodes, only: [:index] do
    collection do
      get :load_data
      post :pdf
    end
  end

  resources :proceedings, only: [:index, :show, :create]

  resources :declines, only: [:index]

  resources :versions, only: [:index] do
    post :export, on: :collection
  end

  resources :assets, except: [:destroy] do
    member do
      post :change_status
      get :historical
    end
    collection do
      get :autocomplete
      get :admin_assets
      get :search
      get :assignation
      get :devolution
      get :users
      get :departments
      get :recode
    end
  end

  resources :auxiliaries, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :accounts, only: [:index, :show]

  resources :departments, except: [:destroy] do
    post :change_status, on: :member
    get :download, on: :member
  end

  resources :buildings, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :entities

  resources :users, except: [:destroy] do
    post :change_status, on: :member
    get :welcome, on: :collection
    get :download, on: :member
    get :autocomplete, on: :collection
    get :historical, on: :member
  end

  get '/datatables-spanish', to: redirect("#{ Rails.application.config.action_controller.relative_url_root }/locales/dataTables.spanish.txt"), as: :spanish_datatables
  get '/dashboard', to: 'dashboard#index', as: :dashboard
  patch '/dashboard/update_password', to: 'dashboard#update_password', as: :update_password_dashboard
  post '/dashboard/announcements/hide', to: 'dashboard#hide', as: :hide_announcement

  post '/dbf/:model/import', to: 'dbf#import', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'import_dbf'
  get '/dbf/:model', to: 'dbf#index', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'dbf'
  get '/dbf', to: redirect("#{ Rails.application.config.action_controller.relative_url_root }/dbf/buildings"), as: 'migration'

  devise_for :users, controllers: { sessions: "sessions" }, skip: [ :sessions ]
  as :user do
    get '/login' => 'sessions#new', as: :new_user_session
    post '/login' => 'sessions#create', as: :user_session
    delete '/logout' => 'sessions#destroy', as: :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#welcome'
end
