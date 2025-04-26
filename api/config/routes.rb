Rails.application.routes.draw do
  # API namespace for all endpoints
  namespace :api do
    namespace :v1 do
      resources :candidates
      resources :jobs do
        resources :job_applications, only: [:index]
      end
      resources :job_applications
      resources :companies do
        resources :jobs, only: [:index]
      end
      
      resources :recruiters do
        # WhatsApp Business configuration endpoints for recruiters
        resource :whatsapp_business_config, controller: 'whats_app_business_configs', only: [:show, :create, :update, :destroy] do
          post 'test_message', on: :member
        end
      end
      
      # WhatsApp webhook endpoints
      get 'whatsapp_webhooks', to: 'whats_app_webhooks#verify'
      post 'whatsapp_webhooks', to: 'whats_app_webhooks#receive'
    end
  end
  
  # Devise routes
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'api/v1/users/sessions',
    registrations: 'api/v1/users/registrations'
  }
  
  # Default route redirects to api/v1
  root to: redirect('/api/v1')
end
