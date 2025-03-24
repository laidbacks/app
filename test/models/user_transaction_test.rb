require "test_helper"

class UserTransactionTest < ActiveSupport::TestCase
  # Tests demonstrating transaction behavior in Rails tests

  # By default, all tests are wrapped in a transaction that is rolled back
  test "changes in one test don't affect other tests" do
    initial_count = User.count

    # Create a new user that should be rolled back after the test
    User.create!(username: "transaction_test_user", password: "password123")

    # Verify the user was created in this test
    assert_equal initial_count + 1, User.count
    assert User.exists?(username: "transaction_test_user")
  end

  # This test should not see the user created in the previous test
  # because that transaction was rolled back
  test "previous test changes are not visible" do
    # The user from the previous test should not exist
    assert_not User.exists?(username: "transaction_test_user")
  end

  # Test that current_transaction works as expected even with the
  # implicit transaction around tests
  test "current_transaction method works correctly" do
    # The implicit transaction around tests doesn't interfere with
    # application-level semantics of current_transaction
    assert_not_nil User.connection.current_transaction

    # Start a new transaction
    User.transaction do
      # Now we should have a transaction
      assert_not_nil User.connection.current_transaction
      # Check if we're in a transaction
      assert User.connection.transaction_open?
    end
  end

  # Test nested transactions with savepoints
  test "nested transactions work correctly" do
    # In Rails, nested transactions are implemented with savepoints
    # The behavior of rollbacks is a bit different than real nested transactions
    initial_count = User.count
    outer_username = "outer_transaction_#{Time.now.to_i}"
    inner_username = "inner_transaction_#{Time.now.to_i}"

    # Start an outer transaction
    User.transaction do
      # Create a user in the outer transaction
      outer_user = User.create!(username: outer_username, password: "password123")
      assert User.exists?(username: outer_username)

      # Start a nested transaction with a savepoint
      begin
        User.transaction(requires_new: true) do
          # Create a user in the inner transaction
          inner_user = User.create!(username: inner_username, password: "password123")
          assert User.exists?(username: inner_username)

          # Roll back the inner transaction only
          raise ActiveRecord::Rollback
        end
      rescue
        # Should not reach here
        flunk "Inner transaction rollback should not propagate"
      end

      # The inner transaction should have been rolled back
      # But in Rails, the parent transaction is not affected by child rollbacks
      assert User.exists?(username: outer_username)
      # This is key: in Rails with savepoints, the inner transaction changes *should* be rolled back
      assert_not User.exists?(username: inner_username)

      # Roll back the outer transaction
      raise ActiveRecord::Rollback
    end

    # After the outer transaction, all changes should be rolled back
    assert_equal initial_count, User.count
    assert_not User.exists?(username: outer_username)
    assert_not User.exists?(username: inner_username)
  end
end
