# app/controllers/private_controller.rb

# frozen_string_literal: true
class PrivateController < ActionController::API
  include Secured

  def private
    res = {name: @auth_user_name, id: @auth_user_id}
    render json: res
  end
end