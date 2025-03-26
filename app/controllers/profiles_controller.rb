class ProfilesController < ApplicationController
  before_action :require_login

  # GET /profile
  def show
    @user = current_user
  end

  # GET /profile/edit
  def edit
    @user = current_user
  end

  # PATCH/PUT /profile
  def update
    @user = current_user

    respond_to do |format|
      if @user.update(profile_params)
        format.html { redirect_to profile_path, notice: "Profile updated successfully!" }
        format.json { render json: @user.profile_data, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # POST /profile/avatar
  def update_avatar
    service = ProfileAvatarService.new(current_user)
    result = service.process_avatar(params[:avatar])

    respond_to do |format|
      if result[:success]
        format.html { redirect_to profile_path, notice: result[:message] }
        format.json { render json: { message: result[:message], avatar_url: result[:avatar_url] }, status: :ok }
      else
        format.html { redirect_to profile_path, alert: result[:message] }
        format.json { render json: { error: result[:message] }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile/avatar
  def remove_avatar
    service = ProfileAvatarService.new(current_user)
    result = service.remove_avatar

    respond_to do |format|
      if result[:success]
        format.html { redirect_to profile_path, notice: result[:message] }
        format.json { render json: { message: result[:message] }, status: :ok }
      else
        format.html { redirect_to profile_path, alert: result[:message] }
        format.json { render json: { error: result[:message] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def profile_params
    params.permit(:username, :full_name, :email, :bio, :timezone)
  end
end
