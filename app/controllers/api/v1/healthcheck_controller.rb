class Api::V1::HealthcheckController < ApplicationController
  def get
    render status: :ok
  end
end
