Rails.application.routes.draw do

  controller :register do
    get 'register/info' => :info
    post 'register/info'=> :create, as: 'register'
  end
  devise_for :users, :controllers => { omniauth_callbacks: 'user/omniauth_callbacks' }
  resources :calendars
  resources :posts do
    resources :comments, only: [:create, :destroy]
  end
  root 'welcome#index'
end
