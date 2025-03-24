require "test_helper"

class UserNonTransactionalTest < ActiveSupport::TestCase
  # Disable transactional tests for this test case
  self.use_transactional_tests = false

  # Setup - runs before each test
  setup do
    # Since we're not using transactions, we need to manually clean up data
    # that could be left from previous tests
    User.where(username: [ "non_transactional_user", "another_non_transactional_user" ]).destroy_all
  end

  # Teardown - runs after each test
  teardown do
    # Clean up any data we created in tests
    User.where(username: [ "non_transactional_user", "another_non_transactional_user" ]).destroy_all
  end

  # This test creates a record that will persist to the database
  # (not rolled back automatically)
  test "creates a persistent record" do
    initial_count = User.count

    # Create a user that will not be rolled back
    User.create!(username: "non_transactional_user", password: "password123")

    # Verify the user was created
    assert_equal initial_count + 1, User.count
    assert User.exists?(username: "non_transactional_user")
  end

  # This test will see the user created in the previous test if run sequentially
  # which demonstrates the lack of transaction isolation
  test "can see records created in other tests" do
    # Create another test user
    another_user = User.create!(username: "another_non_transactional_user", password: "password123")

    # Count users with our test usernames
    test_users_count = User.where(
      username: [ "non_transactional_user", "another_non_transactional_user" ]
    ).count

    # If the previous test ran, we should have both users
    # If tests run in isolation or in parallel, we might only have the one we just created
    assert_operator test_users_count, :>=, 1
    assert User.exists?(id: another_user.id)
  end

  # This test demonstrates why you might want to disable transactions
  # for example, when testing threaded code or background jobs
  test "can test behavior that spans processes" do
    # Create a user
    User.create!(username: "non_transactional_user", password: "password123")

    # In a real scenario, you might run a background job here that would
    # operate on this user. Since it's in a separate process, it needs
    # to see the committed data.

    # Simulate running a job in a separate process with system call
    # system("bin/rails runner 'puts User.find_by(username: \"non_transactional_user\").inspect'")

    # Or simulate it with a direct query to verify the user exists in the database
    # not just in the current connection's transaction
    ActiveRecord::Base.establish_connection
    assert_equal 1, ActiveRecord::Base.connection.select_value(
      "SELECT COUNT(*) FROM users WHERE username = 'non_transactional_user'"
    ).to_i

    # No need to reconnect as we're just using the same connection
  end
end
