class Api::V1::SessionsController < ApplicationController
  include CreateToken
  # ログイン
  def login
    user = User.find_by(email: params[:email], register_type: 1)
    if user.auth_code != 0
      render status: :bad_request
    elsif user&.authenticate(params[:password])
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
      logger.error "google login error(unauthorized): #{e}"
      render json: { error: e }, status: :unauthorized
    end
  end

  # 新規登録
  def register
    begin
      random_number = rand(100000..999999)
      auth_code = "%06d" % random_number
      # メールアドレスの重複チェック
      u = User.find_by(email: params[:email])
      if u
        if u.auth_code == 0
          # 認証済み（auth_code=0）のユーザの場合
          render json: { error: "メールアドレスがすでに使用されています。" }, status: :conflict
          return
        else
          # メールアドレスが未認証の場合は、認証コードを再送信
          u.update(auth_code: auth_code, password_digest: BCrypt::Password.create(params[:password]), name: params[:name])
          UserMailer.with(email: params[:email], auth_code: auth_code).auth_mail.deliver_now
          render json: { message: "register ok" }, status: :ok
          return
        end
      end
      ActiveRecord::Base.transaction do
        if params[:type] != 1
          auth_code = 0
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
          auth_code: auth_code,
        )
        user.save!
        group.update(
          manage_user: user.id,
        )
        # create_token(user.id)
        UserMailer.with(email: params[:email], auth_code: auth_code).auth_mail.deliver_now
        render json: { message: "register ok" }, status: :ok
      end
    rescue ActiveRecord::RecordInvalid => e
      logger.error "register error(unprocessable_entity): #{e}"
      render json: {
               errors: e.record.errors.full_messages,
             },
             status: :unprocessable_entity
    rescue => e
      logger.error "register error(internal_server_error): #{e}"
      render json: { error: e }, status: :internal_server_error
    end
  end

  # メールアドレス認証
  def auth_code
    begin
      logger.info "email=#{params[:email]}"
      user = User.find_by(email: params[:email])
      logger.info "user.auth_code=#{user.auth_code}"
      if user.auth_code == params[:code].to_i
        valid_time = Time.now - user.updated_at
        # 有効期限は5分
        if valid_time < 300
          user.update(auth_code: 0)
          render json: { message: "register ok" }, status: :ok
        else
          render json: { message: "expired" }, status: :unauthorized
        end
      else
        render json: { message: "invalid code" }, status: :unauthorized
      end
    rescue => e
      logger.error "auth code error(internal_server_error): #{e}"
      render json: { error: e }, status: :internal_server_error
    end
  end

  # 認証コードの再送信
  def resend_code
    begin
      random_number = rand(100000..999999)
      auth_code = "%06d" % random_number
      user = User.find_by(email: params[:email])
      user.update(auth_code: auth_code)
      UserMailer.with(email: params[:email], auth_code: auth_code).auth_mail.deliver_now
      render json: { message: "register ok" }, status: :ok
    rescue => e
      logger.error "resend code error: #{e}"
      render json: { error: e }, status: :internal_server_error
    end
  end

  # グループへの参加（子として新規登録）
  def join
    begin
      random_number = rand(100000..999999)
      auth_code = "%06d" % random_number
      # メールアドレスの重複チェック
      u = User.find_by(email: params[:email])
      if u
        if u.auth_code == 0
          # 認証済み（auth_code=0）のユーザの場合
          render json: { error: "メールアドレスがすでに使用されています。" }, status: :conflict
          return
        else
          # メールアドレスが未認証の場合は、認証コードを再送信
          u.update(auth_code: auth_code, password_digest: BCrypt::Password.create(params[:password]), name: params[:name])
          session[:email] = params[:email]
          UserMailer.with(email: params[:email], auth_code: auth_code).auth_mail.deliver_now
          render json: { message: "register ok" }, status: :ok
          return
        end
      end
      # グループIDを取得
      payload, = JWT.decode(params[:group], ENV["TOKEN_SECRET"])

      if params[:type] != 1
        auth_code = 0
      end
      # DBへ登録処理
      user = User.create!(
        email: params[:email],
        name: params[:name],
        password_digest: BCrypt::Password.create(params[:password]),
        group_id: payload["data"]["group_id"],
        register_type: params[:type],
        auth_code: auth_code,
      )
      session[:email] = params[:email]
      UserMailer.with(email: params[:email], auth_code: auth_code).auth_mail.deliver_now
      render json: { message: "register ok" }, status: :ok
    rescue => e
      logger.error "join error(internal_server_error): #{e}"
      render json: { message: e }, status: :internal_server_error
    end
  end

  # 招待リンクから管理者の名前を取得
  def get_parent_name
    begin
      payload, = JWT.decode(params[:group], ENV["TOKEN_SECRET"])
      name = payload["data"]["parent_name"]
      render json: { name: name }, status: :ok
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
