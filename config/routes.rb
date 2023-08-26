Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get '/public', to: 'public#public'
  get '/private', to: 'private#private'
  post '/login', to: 'login#login'
  post '/event', to: 'event#create'
  # put '/event/:id', to: 'event#update'
  # get '/event', to: 'event#get_all'
  # get '/event/:id', to: 'event#get_one'
  # delete '/event/:id' to: 'event#delete'
end
