Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :regis do
    resources :charts
    resources :patients
    resources :filings
  end

  get 'overviews/patient_info'
  get 'overviews/chart_name'
  get 'overviews/chart_date'
  get 'overviews/statistics'

  get 'filings/image/:id', to: 'filings#image', as: 'image_regi_filing'

  get "up" => "rails/health#show", as: :rails_health_check

  root "regis#index"
end
