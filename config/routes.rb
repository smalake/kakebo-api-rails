Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # 認証関連
      post "/login", to: "sessions#login"
      post "/google-login", to: "sessions#google_login"
      post "/register", to: "sessions#register"
      post "/join", to: "sessions#join"
      get "/get-name/:group", to: "sessions#get_parent_name", constraints: { group: /[^\/]+/ }
      get "/login-check", to: "sessions#login_check"
      post "/auth-code", to: "sessions#auth_code"
      get "/resend-code", to: "sessions#resend_code"
      # get "/refresh", to: "sessions#refresh"

      # イベント
      post "/event", to: "event#create"
      put "/event/:id", to: "event#update"
      get "/event", to: "event#get_all"
      get "/event/:id", to: "event#get_one"
      delete "/event/:id", to: "event#delete"
      get "/revision", to: "event#revision"

      # プライベートイベント
      put "/private/:id", to: "private#update"
      get "/private", to: "private#get_all"
      get "/private/:id", to: "private#get_one"
      delete "/private/:id", to: "private#delete"

      # 設定
      get "/display-name", to: "setting#get"
      put "/display-name", to: "setting#update"
      post "/logout", to: "setting#logout"
      get "/invite", to: "setting#invite"
      get "/is-parent", to: "setting#is_parent"
      post "/send-mail", to: "setting#send_mail"

      # ヘルスチェック用
      get "/health-check", to: "healthcheck#get"
    end
  end
end
