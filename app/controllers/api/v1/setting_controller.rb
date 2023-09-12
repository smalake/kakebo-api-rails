class Api::V1::SettingController < ApplicationController
  include Secured

  def get
    begin
      user = User.find_by(id: @auth_user_id)
      render json: { "name" => user.name }, status: :ok
    rescue => e
      render json: {
               message: "Failed to get Name",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  def update
    begin
      user = User.find_by(id: @auth_user_id)
      user.update(name: params[:name])
      render json: { message: "Name update successfully" }, status: :ok
    rescue => e
      render json: {
               message: "Failed to update Name",
               errors: e,
             },
             status: :unprocessable_entity
    end
  end

  # ログアウト
  def logout
    begin
      cookies.delete :jwt
      render status: :ok
    rescue => e
      render json: { message: e }, status: :internal_server_error
    end
  end

  # グループへの招待リンクを発行
  def invite
    begin
      user = User.find_by(id: @auth_user_id)
      data = { group_id: user.group_id, parent_name: user.name }
      token = JWT.encode({ data: data, exp: Time.current.since(10.minute).to_i }, ENV["TOKEN_SECRET"])

      render json: { url: "#{ENV["FRONT_URL"]}/join/#{token}" }, status: :ok
    rescue => e
      render json: { message: "faild to generate invite link", error: e }, status: :internal_server_error
    end
  end
end
