require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test User model
  test "should not save user without username" do
    user = User.new
    assert_not user.save, "Saved the user without an username"
  end

  test "should save user with username and password" do
    user = User.new(username: "test", password: "123456")
    assert user.save, "Did not save the user with an username and password"
  end


  test "should not save user without password" do
    user = User.new(username: "test1")
    assert_not user.save, "Saved the user without a password"
  end

  test "should not save user with short password" do
    user = User.new(username: "test2", password: "12345")
    assert_not user.save, "Saved the user with a short password"
  end
end
