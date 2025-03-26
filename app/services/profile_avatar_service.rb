class ProfileAvatarService
  VALID_CONTENT_TYPES = [ "image/jpeg", "image/png", "image/gif" ].freeze
  MAX_FILE_SIZE = 5.megabytes

  def initialize(user)
    @user = user
  end

  # Process and validate avatar upload
  # @param avatar_params [ActionDispatch::Http::UploadedFile] The uploaded file
  # @return [Hash] Result with :success boolean and :message string
  def process_avatar(avatar_params)
    return { success: false, message: "No avatar was provided" } unless avatar_params.present?

    begin
      # Check avatar file size and type
      validate_avatar(avatar_params)

      # Process and store the avatar
      # Note: In a real implementation, this would save the file to a storage service like AWS S3
      # For this example, we'll just set a placeholder URL
      avatar_url = process_and_store_avatar(avatar_params)

      # Update the user's avatar
      @user.update(avatar: avatar_url)

      { success: true, message: "Avatar updated successfully", avatar_url: avatar_url }
    rescue StandardError => e
      { success: false, message: e.message }
    end
  end

  # Remove the user's avatar
  # @return [Hash] Result with :success boolean and :message string
  def remove_avatar
    if @user.avatar.present?
      # Remove avatar from storage
      # In a real implementation, this would delete the file from storage

      # Update user record
      if @user.update(avatar: nil)
        { success: true, message: "Avatar removed successfully" }
      else
        { success: false, message: "Unable to remove avatar" }
      end
    else
      { success: false, message: "No avatar to remove" }
    end
  end

  private

  def validate_avatar(avatar)
    # Check file size (max 5MB)
    if avatar.size > 5.megabytes
      raise "Avatar file is too large (maximum is 5MB)"
    end

    # Check file type
    permitted_types = %w[image/jpeg image/png image/gif]
    unless permitted_types.include?(avatar.content_type)
      raise "Avatar must be a JPEG, PNG, or GIF file"
    end
  end

  def process_and_store_avatar(avatar)
    # In a real implementation, this would:
    # 1. Process the image (resize, compress, etc.)
    # 2. Store it in a storage service like AWS S3
    # 3. Return the URL to the stored image

    # For this example, we'll return a placeholder URL
    # In practice, you'd want to use Active Storage or a gem like Carrierwave or Shrine
    "https://example.com/avatars/#{@user.id}-#{Time.now.to_i}.jpg"
  end
end
