Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # 認証関連
      post "/login", to: "sessions#login"
      post "/logout", to: "sessions#logout"
      post "/register", to: "sessions#register"
      get "/refresh", to: "sessions#refresh"

      # イベント
      post "/event", to: "event#create"
      put "/event/:id", to: "event#update"
      get "/event", to: "event#get_all"
      get "/event/:id", to: "event#get_one"
      delete "/event/:id", to: "event#delete"

      # 名前設定
      get "/display-name", to: "setting#get"
      put "/display-name", to: "setting#update"
    end
  end
end
