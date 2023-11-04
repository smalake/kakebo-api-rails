class Api::V1::PatternController < ApplicationController
  include Secured
  # パターンを取得
  def get
    begin
      all_data = Pattern.where(user_id: @auth_user_id)
      result = []
      all_data.each do |data|
        pattern = {
          "id" => data.id,
          "store_name" => data.store_name,
          "category" => data.category,
        }
        result.push(pattern)
      end
      render json: result, status: :ok
    rescue => e
      logger.error "failed to get pattern: #{e}"
      render status: :internal_server_error
    end
  end

  #パターンの登録
  def register
    begin
      # 登録されているパターンの件数チェック
      pattern = Pattern.where(user_id: @auth_user_id).count
      if pattern < 3
        Pattern.create!(
          user_id: @auth_user_id,
          store_name: params[:store_name],
          category: params[:category],
        )
        render status: :ok
      else
        render status: :forbidden
      end
    rescue => e
      logger.error "faild to register pattern: #{e}"
      render status: :internal_server_error
    end
  end

  #パターンの更新
  def update
    begin
      pattern = Pattern.find(params[:id])
      if pattern.user_id != @auth_user_id
        render status: :forbidden
      else
        pattern.update(
          store_name: params[:store_name],
          category: params[:category],
        )
        render status: :ok
      end
    rescue => e
      logger.error "faild to update pattern: #{e}"
      render status: :internal_server_error
    end
  end

  #パターンの削除
  def delete
    begin
      pattern = Pattern.find(params[:id])
      if pattern.user_id != @auth_user_id
        render status: :forbidden
      else
        pattern.destroy
        render status: :ok
      end
    rescue => e
      logger.error "faild to delete pattern: #{e}"
      render status: :internal_server_error
    end
  end
end
