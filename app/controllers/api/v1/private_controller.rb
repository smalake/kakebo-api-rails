class Api::V1::PrivateController < ApplicationController
  include Secured
  # イベントの更新
  def update
    begin
      event = Private.find(params[:id])
      event.update(
        amount: params[:amount],
        category: params[:category],
        store_name: params[:store_name],
        date: params[:date],
      )
      render json: { message: "Private Event updated successfully" }, status: :ok
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
    grouping_events_private(all_data)
  end

  # 全プライベートイベントをグルーピング
  def grouping_events_private(all_data)
    begin
      events = {}
      totals = {}
      graphs = {}

      all_data.each do |data|
        format_date = Time.zone.parse(data.date)

        event = {
          "id" => data.id,
          "amount" => data.amount,
          "category" => data.category,
          "store_name" => data.store_name,
          "data" => data.date,
          "created_at" => data.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          "updated_at" => data.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
        }

        # イベントを格納
        if events.key?(format_date.strftime("%Y-%m-%d"))
          events[format_date.strftime("%Y-%m-%d")].push(event)
        else
          events[format_date.strftime("%Y-%m-%d")] = [event]
        end

        # 月ごとの合計
        if totals.key?(format_date.strftime("%Y-%m"))
          totals[format_date.strftime("%Y-%m")] += data.amount
        else
          totals[format_date.strftime("%Y-%m")] = data.amount
        end

        # グラフ用データ
        if graphs.key?(format_date.strftime("%Y-%m"))
          graphs[format_date.strftime("%Y-%m")][
            data.category
          ] += data.amount
        else
          graph = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          graph[data.category] = data.amount
          graphs[format_date.strftime("%Y-%m")] = graph
        end
      end
      render json: { "event" => events, "total" => totals, "graph" => graphs }, status: :ok
    rescue => e
      render json: {
               message: "Private Event grouping failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # 指定したイベントを取得
  def get_one
    begin
      data = Private.find(params[:id])

      result = {
        "amount" => data.amount,
        "category" => data.category,
        "store_name" => data.store_name,
        "date" => data.date,
        "created_at" => data.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        "updated_at" => data.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
      }
      render json: result, status: :ok
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
      Private.find(params[:id]).destroy
      render json: { message: "Private Event delete success" }, status: :ok
    rescue => e
      render json: {
               message: "Private Event delete failed",
               errors: e,
             },
             status: :unprocessable_entity
    end
  end
end
