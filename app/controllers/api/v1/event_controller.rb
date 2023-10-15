class Api::V1::EventController < ApplicationController
  include Secured

  # イベントの新規作成
  def create
    if params[:isPrivate] == 1
      private_event(params)
    else
      group_event(params)
    end
  end

  # グループ用家計簿に登録
  def group_event(params)
    begin
      user = User.find(@auth_user_id)
      ActiveRecord::Base.transaction do
        if params[:amount2] == 0
          event = Event.new(
            amount: params[:amount1],
            category: params[:category1],
            store_name: params[:store_name],
            date: params[:date],
            create_user: @auth_user_id,
            update_user: @auth_user_id,
            group_id: user.group_id,
          )
          event.save!
          event_id = [event.id]
        else
          event1 =
            Event.new(
              amount: params[:amount1] - params[:amount2],
              category: params[:category1],
              store_name: params[:store_name],
              date: params[:date],
              create_user: @auth_user_id,
              update_user: @auth_user_id,
              group_id: user.group_id,
            )
          event1.save!
          event2 = Event.create!(
            amount: params[:amount2],
            category: params[:category2],
            store_name: params[:store_name],
            date: params[:date],
            create_user: @auth_user_id,
            update_user: @auth_user_id,
            group_id: user.group_id,
          )
          event_id = [event1.id, event2.id]
        end
        # リビジョンの更新
        group = Group.find(user.group_id)
        group.update(revision: group.revision + 1)
        render json: { message: "Event register success", data: event_id }, status: :ok
      end
    rescue => e
      render json: {
               message: "Event register failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # 個人用家計簿に登録
  def private_event(params)
    begin
      ActiveRecord::Base.transaction do
        if params[:amount2] == 0
          event = Private.create!(
            amount: params[:amount1],
            category: params[:category1],
            store_name: params[:store_name],
            date: params[:date],
            user_id: @auth_user_id,
          )
          event_id = [event.id]
        else
          event1 =
            Private.new(
              amount: params[:amount1] - params[:amount2],
              category: params[:category1],
              store_name: params[:store_name],
              date: params[:date],
              user_id: @auth_user_id,
            )
          event1.save!
          event2 = Private.create!(
            amount: params[:amount2],
            category: params[:category2],
            store_name: params[:store_name],
            date: params[:date],
            user_id: @auth_user_id,
          )
          event_id = [event1.id, event2.id]
        end
        render json: { message: "Private Event register success", data: event_id }, status: :ok
      end
    rescue => e
      render json: {
               message: "Event register failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # イベントの更新
  def update
    begin
      ActiveRecord::Base.transaction do
        event = Event.find(params[:id])
        event.update(
          amount: params[:amount],
          category: params[:category],
          store_name: params[:store_name],
          date: params[:date],
          update_user: @auth_user_id,
        )
        # リビジョンの更新
        user = User.find(@auth_user_id)
        group = Group.find(user.group_id)
        group.update(revision: group.revision + 1)
      end
      render json: { message: "Event updated successfully" }, status: :ok
    rescue => e
      render json: {
               message: "Event update failed",
               errors: e,
             },
             status: :unprocessable_entity
    end
  end

  # ユーザの全イベントを取得
  def get_all
    # グループIDを取得するためユーザ情報を取得する
    user = User.find(@auth_user_id)

    all_data = Event.where(group_id: user.group_id)
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
               message: "All Event get to failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # 指定したイベントを取得
  def get_one
    begin
      id = params[:id]
      data =
        Event
          .select(
            "events.amount",
            "events.category",
            "events.store_name",
            "events.date",
            "events.created_at",
            "events.updated_at",
            "users1.name as create_user",
            "users2.name as update_user"
          )
          .joins(
            "LEFT JOIN users AS users1 ON events.create_user = users1.id"
          )
          .joins(
            "LEFT JOIN users AS users2 ON events.update_user = users2.id"
          )
          .where("events.id = ?", id)
          .first

      result = {
        "amount" => data.amount,
        "category" => data.category,
        "store_name" => data.store_name,
        "date" => data.date,
        "create_user" => data.create_user,
        "update_user" => data.update_user,
        "created_at" => data.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        "updated_at" => data.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
      }
      render json: result, status: :ok
    rescue => e
      render json: {
               message: "Event get failed",
               errors: e,
             },
             status: :internal_server_error
    end
  end

  # 指定したイベントを削除
  def delete
    begin
      ActiveRecord::Base.transaction do
        Event.find(params[:id]).destroy
        # リビジョンの更新
        user = User.find(@auth_user_id)
        group = Group.find(user.group_id)
        group.update(revision: group.revision + 1)
      end
      render json: { message: "Event delete success" }, status: :ok
    rescue => e
      render json: {
               message: "Event delete failed",
               errors: e,
             },
             status: :unprocessable_entity
    end
  end
end
