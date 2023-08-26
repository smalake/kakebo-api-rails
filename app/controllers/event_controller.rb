class EventController < ApplicationController
    include Secured

    # イベントの新規作成
    def create
        begin
            user = User.find_by(uid: @auth_user_id)
            ActiveRecord::Base.transaction do
                if params[:amount2] == 0
                    Event.create!(
                        amount: params[:amount1],
                        category: params[:category1],
                        store_name: params[:store_name],
                        date: params[:date],
                        create_user: @auth_user_id,
                        update_user: @auth_user_id,
                        group_id: user.group_id
                    )
                else
                    event1 = Event.new(
                        amount: params[:amount1] - params[:amount2],
                        category: params[:category1],
                        store_name: params[:store_name],
                        date: params[:date],
                        create_user: @auth_user_id,
                        update_user: @auth_user_id,
                        group_id: user.group_id
                    )
                    event1.save!
                    Event.create!(
                        amount: params[:amount2],
                        category: params[:category2],
                        store_name: params[:store_name],
                        date: params[:date],
                        create_user: @auth_user_id,
                        update_user: @auth_user_id,
                        group_id: user.group_id
                    )
                end
                render json: { message: 'Event register success'}, status: :ok
            end
        rescue => e
            render json: {message: 'Event register failed', errors: e}, status: :internal_server_error
        end
    end

    # イベントの更新
    def update
        begin
            event = Event.find(params[:id])
            event.update(
                amount: params[:amount],
                category: params[:category],
                store_name: params[:store_name],
                date: params[:date],
                update_user: @auth_user_id
            )
            render json: { message: 'Event updated successfully' }, status: :ok
        rescue => e
            render json: { message: 'Event update failed', errors: e }, status: :unprocessable_entity
        end
    end

    # ユーザの全イベントを取得
    def get_all
        # グループIDを取得するためユーザ情報を取得する
        user = User.find_by(uid: @auth_user_id)

        @all_data = Event.where(group_id: user.group_id)
        result = grouping_events
        puts result
        render json: result, status: :ok
    end

    # 全イベントをグルーピング
    def grouping_events
        begin
            events = {}
            totals = {}
            graphs = {}

            @all_data.each do |data|
                format_date = Time.zone.parse(data.date)

                event = {
                    'id' => data.id,
                    'amount' => data.amount,
                    'category' => data.category,
                    'store_name' => data.store_name,
                    'data' => data.date,
                    'create_user' => data.create_user,
                    'update_user' => data.update_user,
                    'created_at' => data.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                    'updated_at' => data.updated_at.strftime('%Y-%m-%d %H:%M:%S')
                }

                # イベントを格納
                if events.key?(format_date.strftime('%Y-%m-%d'))
                    events[format_date.strftime('%Y-%m-%d')].push(event)
                else
                    events[format_date.strftime('%Y-%m-%d')] = [event]
                end

                # 月ごとの合計
                if totals.key?(format_date.strftime('%Y-%m'))
                    totals[format_date.strftime('%Y-%m')] += data.amount
                else
                    totals[format_date.strftime('%Y-%m')] = data.amount
                end

                # グラフ用データ
                if graphs.key?(format_date.strftime('%Y-%m'))
                    graphs[format_date.strftime('%Y-%m')][data.category] += data.amount
                else
                    graph = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                    graph[data.category] = data.amount
                    graphs[format_date.strftime('%Y-%m')] = graph
                end
            end
            return {'event' => events, 'total' => totals, 'graph' => graphs}
        rescue => e
            render json: {message: 'Event grouping failed', errors: e}, status: :internal_server_error
        end
    end

    def get_one
        begin
            id = params[:id]
            data = Event.select('events.amount', 'events.category', 'events.store_name', 'events.date', 'events.created_at', 'events.updated_at', 'users1.name as create_user', 'users2.name as update_user')
                .joins('LEFT JOIN users AS users1 ON events.create_user = users1.uid')
                .joins('LEFT JOIN users AS users2 ON events.update_user = users2.uid')
                .where('events.id = ?', id).first

            result = {
                'amount' => data.amount,
                'category' => data.category,
                'store_name' => data.store_name,
                'date' => data.date,
                'create_user' => data.create_user,
                'update_user' => data.update_user,
                'created_at' => data.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'updated_at' => data.updated_at.strftime('%Y-%m-%d %H:%M:%S')
            } 
            render json: result, status: :ok
        rescue => e
            render json: {message: 'Event get failed', errors: e}, status: :internal_server_error
        end
    end

    # def delete

    # end
end
