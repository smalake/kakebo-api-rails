class Api::V1::HomeController < ApplicationController
  before_action :verify_token

  def test
    render json: { 'message': "Hello world" }, status: :ok
  end

  private

  def verify_token
    auth_header = request.headers["Authorization"]
    return render status: :unauthorized unless auth_header

    token = auth_header.split(" ")[1]

    begin
      payload, = JWT.decode(token, ENV["TOKEN_SECRET"])
    rescue JWT::ExpiredSignature
      return render json: { 'error': "token expired" }, status: :forbidden
    rescue JWT::VerificationError
      return render json: { 'error': "unauthorized" }, status: :unauthorized
    rescue => e
      return render json: { 'error': e }, status: :internal_server_error
    end
  end
end
