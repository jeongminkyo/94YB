Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'user/omniauth_callbacks' }
  resources :calendars
  root 'welcome#index'
end
