class ProfileAvatarService
  VALID_CONTENT_TYPES = [ "image/jpeg", "image/png", "image/gif" ].freeze
  MAX_FILE_SIZE = 5.megabytes

  def initialize(user)
    @user = user
  end

  # Process and validate avatar upload
  # @param avatar_param [ActionDispatch::Http::UploadedFile] The uploaded file
  # @return [Hash] Result with :success boolean and :message string
  def process_avatar(avatar_param)
    return { success: false, message: "No file uploaded" } unless avatar_param

    # Validate file size
    if avatar_param.size > MAX_FILE_SIZE
      return { success: false, message: "File size exceeds maximum limit (5MB)" }
    end

    # Validate content type
    unless VALID_CONTENT_TYPES.include?(avatar_param.content_type)
      return { success: false, message: "Invalid file type. Please upload a JPEG, PNG, or GIF image." }
    end

    # Process and store the avatar
    begin
      # For simplicity, we're assuming Active Storage is configured
      # In a real app, this would attach the image to the user record
      @user.avatar.attach(avatar_param)

      # Set the avatar URL on the user model
      avatar_url = Rails.application.routes.url_helpers.rails_blob_url(@user.avatar)
      @user.update(avatar: avatar_url)

      { success: true, message: "Avatar uploaded successfully", avatar_url: avatar_url }
    rescue => e
      Rails.logger.error("Avatar upload failed: #{e.message}")
      { success: false, message: "Failed to process avatar upload" }
    end
  end

  # Remove the user's avatar
  # @return [Hash] Result with :success boolean and :message string
  def remove_avatar
    if @user.avatar.present?
      @user.avatar.purge
      @user.update(avatar: nil)
      { success: true, message: "Avatar removed successfully" }
    else
      { success: false, message: "No avatar to remove" }
    end
  end
end
