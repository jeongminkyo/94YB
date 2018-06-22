Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'user/omniauth_callbacks' }
  controller :calendar do
    get '/calendar' => :index
  end
  root 'welcome#index'
end
