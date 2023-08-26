class LoginController < ApplicationController
    include Secured

    def login
        begin
            if User.where(uid: @auth_user_id).exists?
                # ユーザが登録されている場合はログイン
                render json: { message: 'login ok' }, status: :ok
            else
                # ユーザが登録されていない場合はDBへと登録
                ActiveRecord::Base.transaction do
                    # DBへ登録処理
                    group = Group.new(manage_uid: @auth_user_id)
                    group.save!
                    User.create!(
                        uid: @auth_user_id,
                        name: @auth_user_name,
                        group_id: group.id
                    )
                    render json: { message: 'register ok' }, status: :ok
                end
            end
        rescue ActiveRecord::RecordInvalid => e
            render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        rescue
            render json: { errors: 'Not Authenticated' }, status: :unauthorized
        end
    end
end
