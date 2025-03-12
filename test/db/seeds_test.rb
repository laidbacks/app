require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  # This test verifies that seed data can be loaded without errors
  test "seeds load without errors" do
    # Create a new database connection for testing seeds
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    test_db_path = Rails.root.join("tmp", "seeds_test.sqlite3")
    test_config = config.configuration_hash.merge(database: test_db_path)
    
    # Ensure clean state
    FileUtils.rm_f(test_db_path)
    
    # Connect to the test database
    ActiveRecord::Base.establish_connection(test_config)
    
    begin
      # Run migrations to set up schema
      ActiveRecord::Tasks::DatabaseTasks.migrate
      
      # Load seeds
      assert_nothing_raised do
        # Redirect stdout to capture seed output
        original_stdout = $stdout
        $stdout = StringIO.new
        
        load Rails.root.join("db", "seeds.rb")
        
        # Restore stdout
        $stdout = original_stdout
      end
      
      # Specific assertions about your expected seed data
      # These should be customized based on what your seeds.rb file creates
      
      # Example: Check if admin user was created
      admin = User.find_by(username: "admin")
      assert_not_nil admin, "Admin user was not created by seeds"
      
      # Example: Check if specific number of records were created
      # assert_operator User.count, :>=, 5, "Expected seed to create at least 5 users"
      
      # Example: Check if specific records exist with expected attributes
      # assert User.exists?(username: "test_user"), "Expected test_user to be created by seeds"
    ensure
      # Clean up
      ActiveRecord::Base.remove_connection
      FileUtils.rm_f(test_db_path)
      
      # Reconnect to original database
      ActiveRecord::Base.establish_connection
    end
  end
  
  # This test verifies that seeds are idempotent (can be run multiple times safely)
  test "seeds are idempotent" do
    # Skip this test if your seeds are not designed to be idempotent
    # skip "Seeds are not designed to be idempotent"
    
    # Create a new database connection for testing seeds
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    test_db_path = Rails.root.join("tmp", "seeds_idempotent_test.sqlite3")
    test_config = config.configuration_hash.merge(database: test_db_path)
    
    # Ensure clean state
    FileUtils.rm_f(test_db_path)
    
    # Connect to the test database
    ActiveRecord::Base.establish_connection(test_config)
    
    begin
      # Run migrations to set up schema
      ActiveRecord::Tasks::DatabaseTasks.migrate
      
      # Load seeds first time
      load Rails.root.join("db", "seeds.rb")
      
      # Record counts after first seed
      first_run_counts = {
        users: User.count
        # Add other models as needed
      }
      
      # Load seeds second time
      load Rails.root.join("db", "seeds.rb")
      
      # Record counts after second seed
      second_run_counts = {
        users: User.count
        # Add other models as needed
      }
      
      # Compare counts - they should be the same if seeds are idempotent
      assert_equal first_run_counts, second_run_counts, 
        "Seeds are not idempotent. First run: #{first_run_counts}, Second run: #{second_run_counts}"
    ensure
      # Clean up
      ActiveRecord::Base.remove_connection
      FileUtils.rm_f(test_db_path)
      
      # Reconnect to original database
      ActiveRecord::Base.establish_connection
    end
  end
end 