require "test_helper"

class UserDatabaseTest < ActiveSupport::TestCase
  # Setup runs before each test
  setup do
    # Create test users with known attributes
    @user1 = User.create(username: "testuser1", password: "password123")
    @user2 = User.create(username: "testuser2", password: "password456")
  end

  # Teardown runs after each test
  teardown do
    # We could clean up here, but Rails handles this automatically in test env
  end

  # Test database constraints - uniqueness
  test "database enforces username uniqueness" do
    # Try to create user with duplicate username
    duplicate_user = User.new(username: "testuser1", password: "different123")
    
    # Assert that the database raises an exception when saving
    assert_raises(ActiveRecord::RecordNotUnique) do
      # Use insert_all to bypass ActiveRecord validations and hit the DB directly
      User.insert_all([{ 
        username: "testuser1", 
        password_digest: BCrypt::Password.create("different123"),
        created_at: Time.current,
        updated_at: Time.current
      }])
    end
  end

  # Test database queries and performance
  test "user retrieval performance with indices" do
    # Create additional test data
    50.times do |i|
      User.create(username: "performance_user_#{i}", password: "testpass#{i}")
    end

    # Benchmark the query
    time = Benchmark.measure do
      User.where(username: "testuser1").first
    end

    # Simplified assertion - in real world, you might compare against a baseline
    # or use Rails' assert_queries to count the number of queries
    assert_operator time.real, :<, 0.1, "Query took longer than 100ms"
  end

  # Test transactions
  test "transactions can be rolled back" do
    initial_count = User.count
    
    # Start a transaction
    User.transaction do
      User.create(username: "transaction_test", password: "transaction123")
      # Verify user was created within transaction
      assert_equal initial_count + 1, User.count
      
      # Roll back the transaction
      raise ActiveRecord::Rollback
    end
    
    # Verify the user count is back to initial (transaction was rolled back)
    assert_equal initial_count, User.count
  end

  # Test database triggers and calculated fields
  # This is an example - modify based on your actual DB setup
  test "updated_at is automatically set by database" do
    old_updated_at = @user1.updated_at
    sleep(1) # Ensure time difference
    
    # Update the user
    @user1.username = "modified_username"
    @user1.save
    
    # Reload from database to get fresh values
    @user1.reload
    
    # Check that updated_at was changed by the database
    assert_not_equal old_updated_at, @user1.updated_at
  end

  # Test data integrity across related tables
  # This example assumes you add a posts table related to users
  # Uncomment and modify when you have related tables
  # test "deleting user cascades to related posts" do
  #   # Create a post belonging to user1
  #   post = @user1.posts.create(title: "Test Post", content: "Test Content")
  #   
  #   # Delete the user
  #   @user1.destroy
  #   
  #   # Assert the post was also deleted (if you set up cascade deletes)
  #   assert_raises(ActiveRecord::RecordNotFound) do
  #     post.reload
  #   end
  # end

  # Test database connection resilience
  test "reconnects after connection interruption" do
    # Simulate a connection interruption
    ActiveRecord::Base.connection.disconnect!
    
    # Try to use the connection again
    assert_nothing_raised do
      User.count
    end
    
    # Connection should be reestablished automatically
    assert ActiveRecord::Base.connection.active?
  end

  # Test raw SQL execution
  test "can execute raw SQL queries" do
    # Execute raw SQL
    result = ActiveRecord::Base.connection.execute("SELECT COUNT(*) as user_count FROM users")
    
    # Extract the count from the result (SQLite specific)
    count = result.first["user_count"]
    
    # Compare with the expected count from ActiveRecord
    assert_equal User.count, count
  end

  # Test for SQL injection vulnerabilities
  test "prepared statements prevent SQL injection" do
    # Malicious input attempting SQL injection
    malicious_username = "'; DROP TABLE users; --"
    
    # Try to find a user with this username (should use prepared statements)
    safe_result = User.where(username: malicious_username).first
    
    # The query should execute safely without errors
    assert_nil safe_result
    
    # Verify the users table still exists and has our data
    assert_equal 2, User.where(username: ["testuser1", "testuser2"]).count
  end
end 