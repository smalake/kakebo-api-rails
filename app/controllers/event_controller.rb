class EventController < ApplicationController
    include Secured

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

    # def update

    # end

    # def get_all

    # end

    # def get_one

    # end

    # def delete

    # end
end
