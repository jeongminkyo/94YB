Rails.application.routes.draw do

  resources :travel_post_attachments
  resources :travel_posts do
    resources :travel_comments, only: [:create, :destroy]
  end
  resources :post_attachments

  controller :register do
    get 'register/info' => :info
    post 'register/info'=> :create, as: 'register'
  end

  controller :post_like do
    post 'post_like' => :create
    delete 'post_like/:id' => :destroy, as: 'delete_post_like'
  end

  controller :travel_post_like do
    post 'travel_post_like' => :create
    delete 'travel_post_like/:id' => :destroy, as: 'delete_travel_post_like'
  end
  devise_for :users, :controllers => { omniauth_callbacks: 'user/omniauth_callbacks' }
  resources :calendars
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end
  root 'welcome#index'
end
