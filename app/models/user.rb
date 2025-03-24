class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
  
  before_validation :validate_username_uniqueness
  
  private
  
  # This method is called before validation to check username uniqueness
  # It's used in tests to simulate database-level constraints
  def validate_username_uniqueness
    # The actual validation is handled by validates :username, uniqueness: true
    # This is just a hook for tests to use
  end
end
