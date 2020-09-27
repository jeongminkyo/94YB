Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      controller :notices do
        get 'notices' => :notice_list
      end

      controller :travel_posts do
        get 'travel_posts' => :travel_post_list
      end

      controller :cashes do
        get 'cashes' => :cash_list
        post 'cashes' => :create
        get 'user_cashes' => :user_cash_list
        get 'account_info' => :account_info
      end

      controller :users do
        get 'user_list' => :user_list
        post 'push_token' => :upsert_push_token
      end
    end

    namespace :auth do
      controller :users do
        post 'sign_in' => :sign_in
        post 'sign_up' => :sign_up
        post 'token_renewal' => :token_renewal
      end
    end
  end
  resources :notice_attachments
  resources :notices do
    resources :notice_comments, only: [:create, :destroy]
  end

  resources :cashes
  resources :travel_post_attachments
  resources :travel_posts do
    resources :travel_comments, only: [:create, :destroy]
  end
  resources :post_attachments

  controller :register do
    get 'register/info' => :info
    post 'register/info'=> :create, as: 'register'
  end

  controller :kakao do
    get '/keyboard' => :keyboard
    post '/message' => :message

  end
  controller :post_like do
    post 'post_like' => :create
    delete 'post_like/:id' => :destroy, as: 'delete_post_like'
  end

  controller :travel_post_like do
    post 'travel_post_like' => :create
    delete 'travel_post_like/:id' => :destroy, as: 'delete_travel_post_like'
  end

  controller :notice_like do
    post 'notice_like' => :create
    delete 'notice_like/:id' => :destroy, as: 'delete_notice_like'
  end

  resources :calendars
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end

  devise_for :users, :controllers => { omniauth_callbacks: 'user/omniauth_callbacks', registrations: 'user/registrations' }
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'welcome#index'

  match '*not_found', to: 'error#not_found', via: [:all]
end
