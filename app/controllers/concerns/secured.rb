# app/controllers/concerns/secured.rb

# frozen_string_literal: true
module Secured
  extend ActiveSupport::Concern

  included do
    before_action :verify_token
  end

  private

  def verify_token
    auth_header = request.headers["Authorization"]
    return render status: :unauthorized unless auth_header

    token = auth_header.split(" ")[1]

    begin
      payload, = JWT.decode(token, ENV["TOKEN_SECRET"])
      @auth_user_id = payload["data"]["user_id"]
    rescue JWT::ExpiredSignature
      return render json: { 'error': "token expired" }, status: :forbidden
    rescue JWT::VerificationError
      return render json: { 'error': "unauthorized" }, status: :unauthorized
    rescue => e
      return render json: { 'error': e }, status: :internal_server_error
    end
  end
end
