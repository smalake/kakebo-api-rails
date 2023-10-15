class Api::V1::PrivateController < ApplicationController
  include Secured
  # イベントの更新
  def update
    begin
      event = Private.find(params[:id])
      if @auth_user_id != event.user_id
        render json: { message: "forbidden" }, status: :forbidden
      else
        event.update(
          amount: params[:amount],
          category: params[:category],
          store_name: params[:store_name],
          date: params[:date],
        )
        render json: { message: "Private Event updated successfully" }, status: :ok
      end
    rescue => e
      render json: {
               message: "Private Event update failed",
               errors: e,
             },
             status: :unprocessable_entity
    end
  end

  # ユーザの全プライベートイベントを取得
  def get_all
    all_data = Private.where(user_id: @auth_user_id)
    begin
      events = []
      all_data.each do |data|
        format_date = Time.zone.parse(data.date)
        event = {
          "id" => data.id,
          "amount" => data.amount,
          "category" => data.category,
          "store" => data.store_name,
          "date" => format_date.strftime("%Y-%m-%d"),
        }
        events.push(event)
      end
      render json: { "events" => events }, status: :ok
    rescue => e
      render json: {
               message: "Private All Event get to failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # 指定したイベントを取得
  def get_one
    begin
      data = Private.find(params[:id])
      if @auth_user_id != data.user_id
        render json: { message: "forbidden" }, status: :forbidden
      else
        result = {
          "amount" => data.amount,
          "category" => data.category,
          "store_name" => data.store_name,
          "date" => data.date,
          "created_at" => data.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          "updated_at" => data.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
        }
        render json: result, status: :ok
      end
    rescue => e
      render json: {
               message: "Private Event get failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # 指定したイベントを削除
  def delete
    begin
      event = Private.find(params[:id])
      if @auth_user_id != event.user_id
        render json: { message: "forbidden" }, status: :forbidden
      else
        event.destroy
        render json: { message: "Private Event delete success" }, status: :ok
      end
    rescue => e
      render json: {
               message: "Private Event delete failed",
               errors: e,
             },
             status: :unprocessable_entity
    end
  end
end
