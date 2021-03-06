Rails.application.routes.draw do
 
  namespace :admin do
    root "application#index"
    
    resources :projects, only: [:new, :create, :destroy]     
    resources :users do
      member do
        patch :archive
      end
    end
    resources :states, only: [:index, :new , :create] do
      member do
        get :make_default
      end 
    end
  end

 
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'projects#index'

  resources :projects, only: [:index, :show, :edit, :update] do
  	resources :tickets do
      collection do
        get :search
      end
      member do
        post :watch
      end
    end
  end

  # ** since we only have show in attachments controller
  resources :attachments, only: [:show, :new]

  resources :tickets, only: [] do
    resources :comments, only: [:create]
    resources :tags, only: [] do
      member do
        delete :remove
      end
    end
  end

end
