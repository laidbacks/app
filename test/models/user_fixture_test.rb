require "test_helper"

class UserFixtureTest < ActiveSupport::TestCase
  # Tests demonstrating how to use fixtures

  # Test that fixtures are loaded correctly
  test "fixtures are accessible by name" do
    # Access fixture by name
    admin = users(:admin)
    assert_equal "admin_user", admin.username

    # Access multiple fixtures at once
    admin_and_regular = users(:admin, :regular_user)
    assert_equal 2, admin_and_regular.size
    assert_equal [ "admin_user", "regular_joe" ], admin_and_regular.map(&:username).sort
  end

  # Test that dynamically generated fixtures work
  test "dynamically generated fixtures are accessible" do
    # Access one of the dynamically generated fixtures
    user = users(:user_3)
    assert_equal "test_user_3", user.username

    # Verify all generated fixtures exist
    5.times do |n|
      assert users("user_#{n}")
    end
  end

  # Test that fixtures are database-independent
  test "fixtures have proper attributes" do
    admin = users(:admin)

    # Check that the fixture has the expected attributes
    assert_respond_to admin, :username
    assert_respond_to admin, :password_digest
    assert_respond_to admin, :created_at
    assert_respond_to admin, :updated_at
  end

  # Test that fixtures are real Active Record objects
  test "fixtures are Active Record objects" do
    admin = users(:admin)

    # Assert it's an instance of the User model
    assert_instance_of User, admin

    # Can call model methods on fixture
    assert admin.persisted?

    # Can modify and save fixture objects
    admin.username = "modified_admin"
    assert admin.save
    assert_equal "modified_admin", admin.reload.username
  end
end
