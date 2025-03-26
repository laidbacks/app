require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user).to be_valid
    end

    it 'is not valid without a username' do
      user = User.new(
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'is not valid with a duplicate username' do
      User.create(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123'
      )

      user = User.new(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123'
      )

      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("has already been taken")
    end

    it 'validates email format if provided' do
      user = User.new(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123',
        email: 'invalid-email'
      )

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'allows a valid email' do
      user = User.new(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123',
        email: 'test@example.com'
      )

      expect(user).to be_valid
    end

    it 'validates timezone if provided' do
      user = User.new(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123',
        timezone: 'Invalid/Timezone'
      )

      expect(user).not_to be_valid
      expect(user.errors[:timezone]).to include("is not included in the list")
    end

    it 'allows a valid timezone' do
      user = User.new(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123',
        timezone: 'America/New_York'
      )

      expect(user).to be_valid
    end
  end

  describe '#profile_data' do
    it 'returns a hash of profile data' do
      user = User.create(
        username: 'testuser',
        password: 'password123',
        password_confirmation: 'password123',
        full_name: 'Test User',
        email: 'test@example.com',
        bio: 'This is a test bio',
        timezone: 'America/New_York'
      )

      profile = user.profile_data

      expect(profile).to include(
        id: user.id,
        username: 'testuser',
        full_name: 'Test User',
        email: 'test@example.com',
        bio: 'This is a test bio',
        timezone: 'America/New_York'
      )
    end
  end
end
