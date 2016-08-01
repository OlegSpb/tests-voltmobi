Rails.application.routes.draw do

  root 'web/welcome#index'

  scope module: :web do
    namespace :account do
      resource :session, only: [:new, :create, :destroy]

      resources :tasks do
        member do
          patch 'update_state'
        end

        scope module: :task do
          resources :attachments, only: [:new, :create]
        end
      end

    end
  end

end
