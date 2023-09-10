class Api::V1::SessionsController < ApplicationController
  include CreateToken
  # ログイン
  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      create_token(user.id)
    else
      render status: :unauthorized
    end
  end

  # 新規登録
  def register
    begin
      ActiveRecord::Base.transaction do
        # DBへ登録処理
        group = Group.new()
        group.save!
        user = User.new(
          email: params[:email],
          name: params[:name],
          password_digest: BCrypt::Password.create(params[:password]),
          group_id: group.id,
          register_type: params[:type],
        )
        user.save!
        group.update(
          manage_user: user.id,
        )
        create_token(user.id)
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: {
               errors: e.record.errors.full_messages,
             },
             status: :unprocessable_entity
    rescue => e
      render json: { 'message': e }, status: :internal_server_error
    end
  end

  # ログアウト
  def logout
    begin
      cookies.delete :jwt
      render status: :ok
    rescue => e
      render json: { 'message': e }, status: :internal_server_error
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
