Rails.application.routes.draw do
  get "pages/thank_you"
  resources :regis do
    member do
      patch :signup_patient
      delete :destroy_patient_user
      post :revoke_access
    end

    # Everything inside this block gets the "regi_" prefix
    resources :patients do
      member do
        get :handoff_to_patient
      end
    end

    resources :charts   # This creates regi_charts_path
    resources :filings  # This creates regi_filings_path
  end

  # 3. Authentication & Sessions
  resource :session
  resources :passwords, param: :token
  resource :password, only: [ :edit, :update ], as: :authenticated_password

  # 4. Admin Namespace
  namespace :admin do
    resources :users
  end

  get  "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"

  # 5. Overviews & Stats
  get "overviews/patient_info"
  get "overviews/chart_name"
  get "overviews/chart_date"
  get "usage_logs", to: "overviews#usage_logs", as: :usage_logs
  get "signup_records", to: "overviews#signup_records", as: :signup_records
  get "patient_stats", to: "overviews#patient_stats", as: :patient_stats


  get "thank_you", to: "sites#thank_you", as: :sites_thank_you
  get "no_consent", to: "sites#no_consent", as: :no_consent
  get "no_changes", to: "sites#no_changes", as: :no_changes

  # 6. Filings & Health
  get "filings/image/:id", to: "filings#image", as: "image_regi_filing"
  get "up" => "rails/health#show", as: :rails_health_check

  # 7. Root Path
  root "sites#home"
end
