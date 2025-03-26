module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_user

      # GET /api/v1/profile
      def show
        render json: current_user.profile_data, status: :ok
      end

      # PATCH/PUT /api/v1/profile
      def update
        if current_user.update(profile_params)
          render json: current_user.profile_data, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/profile/avatar
      def update_avatar
        service = ProfileAvatarService.new(current_user)
        result = service.process_avatar(params[:avatar])

        if result[:success]
          render json: { message: result[:message], avatar_url: result[:avatar_url] }, status: :ok
        else
          render json: { error: result[:message] }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/profile/avatar
      def remove_avatar
        service = ProfileAvatarService.new(current_user)
        result = service.remove_avatar

        if result[:success]
          render json: { message: result[:message] }, status: :ok
        else
          render json: { error: result[:message] }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:profile).permit(:username, :full_name, :email, :bio, :timezone, :avatar)
      end
    end
  end
end
