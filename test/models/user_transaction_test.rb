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
    assert_nil User.connection.current_transaction.parent
    
    # Start a new transaction
    User.transaction do
      # Now we should have a nested transaction
      assert_not_nil User.connection.current_transaction.parent
    end
  end
  
  # Test nested transactions with savepoints
  test "nested transactions work correctly" do
    initial_count = User.count
    
    # Start an outer transaction
    User.transaction do
      User.create!(username: "outer_transaction", password: "password123")
      
      # Start a nested transaction
      User.transaction do
        User.create!(username: "inner_transaction", password: "password123")
        
        # Verify both users exist within the nested transaction
        assert User.exists?(username: "outer_transaction")
        assert User.exists?(username: "inner_transaction")
        assert_equal initial_count + 2, User.count
        
        # Roll back the inner transaction only
        raise ActiveRecord::Rollback
      end
      
      # The inner transaction changes should be rolled back
      assert User.exists?(username: "outer_transaction")
      assert_not User.exists?(username: "inner_transaction")
      assert_equal initial_count + 1, User.count
    end
    
    # After the outer transaction, all changes should be rolled back
    assert_equal initial_count, User.count
    assert_not User.exists?(username: "outer_transaction")
  end
end 