module CreateToken
  extend ActiveSupport::Concern

  # アクセストークンとリフレッシュトークンを発行
  def create_token(user_id)
    data = { user_id: user_id }
    access_token = JWT.encode({ data: data, exp: Time.current.since(7.day).to_i }, ENV["TOKEN_SECRET"])
    # refresh_token = JWT.encode({ data: data, exp: Time.current.since(7.day).to_i }, ENV["REFRESH_SECRET"])

    #   user.update(refresh_token: refresh_token)

    # cookies[:jwt] = refresh_token
    render json: { accessToken: access_token }, status: :ok
  end
end
