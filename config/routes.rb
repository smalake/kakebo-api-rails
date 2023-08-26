Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/login', to: 'login#login'

  post '/event', to: 'event#create'
  put '/event/:id', to: 'event#update'
  get '/event', to: 'event#get_all'
  get '/event/:id', to: 'event#get_one'
  delete '/event/:id', to: 'event#delete'

  get '/display-name', to: 'setting#get'
  put '/display-name', to: 'setting#update'
end
