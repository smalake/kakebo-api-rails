class Api::V1::SessionsController < ApplicationController
  include CreateToken
  # ログイン
  def login
    user = User.find_by(email: params[:email], register_type: 1)
    if user&.authenticate(params[:password])
      create_token(user.id)
    else
      render status: :unauthorized
    end
  end

  # Googleアカウントでログイン
  def google_login
    begin
      user = User.find_by(email: params[:email], register_type: 2)
      if user != nil
        create_token(user.id)
      else
        render json: { message: "not register user" }, status: :unauthorized
      end
    rescue => e
      render json: { error: e }, status: :unauthorized
    end
  end

  # 新規登録
  def register
    begin
      ActiveRecord::Base.transaction do
        # メールアドレスの重複チェック
        if User.find_by(email: params[:email])
          render json: { error: "メールアドレスがすでに使用されています。" }, status: :conflict
          return
        end

        # DBへ登録処理
        group = Group.new()
        group.save!
        user = User.new(
          email: params[:email],
          password_digest: BCrypt::Password.create(params[:password]),
          name: params[:name],
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

  # グループへの参加（子として新規登録）
  def join
    begin
      # グループIDを取得
      payload, = JWT.decode(params[:group], ENV["TOKEN_SECRET"])
      # DBへ登録処理
      user = User.create!(
        email: params[:email],
        name: params[:name],
        password_digest: BCrypt::Password.create(params[:password]),
        group_id: payload["data"]["group_id"],
        register_type: params[:type],
      )
      create_token(user.id)
    rescue => e
      render json: { 'message': e }, status: :internal_server_error
    end
  end

  # 招待リンクから管理者の名前を取得
  def get_parent_name
    begin
      data = Rails.application.message_verifier(ENV["TOKEN_SECRET"]).verify(params[:group])[:parent_name]
      render json: { name: data }, status: :ok
    rescue => e
      render json: { message: "faild to get parent name", error: e }, status: :internal_server_error
    end
  end

  # トークンからログイン状態をチェック
  def login_check
    auth_header = request.headers["Authorization"]
    return render status: :unauthorized unless auth_header
    token = auth_header.split(" ")[1]
    begin
      payload, = JWT.decode(token, ENV["TOKEN_SECRET"])
      user_id = payload["data"]["user_id"]
      if user_id
        render status: :ok
      else
        render status: :unauthorized
      end
    rescue
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
