class SettingController < ApplicationController
    include Secured

    def get
        begin
            user = User::find_by(uid: @auth_user_id)
            render json: {'name' => user.name}, status: :ok
        rescue => e
            render json: {message: 'Failed to get Name', errors: e}, status: :internal_server_error
        end
    end

    def update
        begin
            user = User.find_by(uid: @auth_user_id)
            user.update(
                name: params[:name]
            )
            render json: { message: 'Name update successfully' }, status: :ok
        rescue => e
            render json: { message: 'Failed to update Name', errors: e }, status: :unprocessable_entity
        end
    end
end
