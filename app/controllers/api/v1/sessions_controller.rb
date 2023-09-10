class Api::V1::SessionsController < ApplicationController
  # アクセストークンとリフレッシュトークンを発行
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      data = { user_id: user.id }
      access_token = JWT.encode({ data: data, exp: Time.current.since(1.day).to_i }, ENV["TOKEN_SECRET"])
      refresh_token = JWT.encode({ data: data, exp: Time.current.since(7.day).to_i }, ENV["REFRESH_SECRET"])

      user.update(refresh_token: refresh_token)

      cookies[:jwt] = refresh_token
      render json: { accessToken: access_token }, status: :ok
    else
      render status: :unauthorized
    end
  end

  # リフレッシュトークンからアクセストークンを発行
  def refresh
    return render status: :unauthorized unless cookies[:jwt]

    refresh_token = cookies[:jwt]
    user = User.find_by(refresh_token: refresh_token)
    return render status: :forbidden unless user

    payload, = JWT.decode(refresh_token, ENV["REFRESH_SECRET"])
    return render status: :forbidden unless payload["data"]["user_id"] == user.id

    data = { user_id: user.id }
    access_token = JWT.encode({ data: data, exp: Time.current.since(30.seconds).to_i }, ENV["TOKEN_SECRET"])

    render json: { accessToken: access_token }, status: :ok
  end
end
