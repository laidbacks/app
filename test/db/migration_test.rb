require "test_helper"

class MigrationTest < ActiveSupport::TestCase
  # This test verifies that all migrations can be run from scratch
  test "migrations can run from scratch" do
    # Skip in CI environment since we typically use schema.rb there
    skip if ENV["CI"]
    
    # Store current version
    original_version = ActiveRecord::Migrator.current_version
    
    # Create a new database connection for testing migrations
    # Note: This assumes SQLite is being used
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    test_db_path = Rails.root.join("tmp", "migration_test.sqlite3")
    test_config = config.configuration_hash.merge(database: test_db_path)
    
    # Ensure clean state
    FileUtils.rm_f(test_db_path)
    
    # Connect to the test database
    migration_conn = ActiveRecord::Base.establish_connection(test_config)
    
    begin
      # Run all migrations from scratch
      assert_nothing_raised do
        ActiveRecord::Tasks::DatabaseTasks.migrate
      end
      
      # Verify all migrations were applied
      current_version = ActiveRecord::Migrator.current_version
      latest_version = ActiveRecord::Migrator.get_all_versions.max || 0
      
      assert_equal latest_version, current_version, 
        "Not all migrations were applied. Current: #{current_version}, Latest: #{latest_version}"
    ensure
      # Clean up
      ActiveRecord::Base.remove_connection
      FileUtils.rm_f(test_db_path)
      
      # Reconnect to original database
      ActiveRecord::Base.establish_connection
    end
  end
  
  # This test verifies migrations can be rolled back
  test "migrations can be rolled back" do
    # Skip in CI environment
    skip if ENV["CI"]
    
    # Get all migration versions
    versions = ActiveRecord::Migrator.get_all_versions
    
    # Skip if no migrations
    skip if versions.empty?
    
    # Create a new database connection for testing migrations
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    test_db_path = Rails.root.join("tmp", "rollback_test.sqlite3")
    test_config = config.configuration_hash.merge(database: test_db_path)
    
    # Ensure clean state
    FileUtils.rm_f(test_db_path)
    
    # Connect to the test database
    ActiveRecord::Base.establish_connection(test_config)
    
    begin
      # Run all migrations
      ActiveRecord::Tasks::DatabaseTasks.migrate
      
      # Get the latest version
      latest_version = ActiveRecord::Migrator.get_all_versions.max || 0
      
      # Try rolling back the latest migration
      assert_nothing_raised do
        ActiveRecord::Tasks::DatabaseTasks.migrate(version: previous_version(latest_version))
      end
      
      # Verify rollback worked
      current_version = ActiveRecord::Migrator.current_version
      assert_not_equal latest_version, current_version, 
        "Migration rollback failed. Still at version: #{current_version}"
      
      # Try running the migration again
      assert_nothing_raised do
        ActiveRecord::Tasks::DatabaseTasks.migrate
      end
      
      # Verify migration worked
      current_version = ActiveRecord::Migrator.current_version
      assert_equal latest_version, current_version, 
        "Migration re-run failed. At version: #{current_version}, expected: #{latest_version}"
    ensure
      # Clean up
      ActiveRecord::Base.remove_connection
      FileUtils.rm_f(test_db_path)
      
      # Reconnect to original database
      ActiveRecord::Base.establish_connection
    end
  end
  
  private
  
  # Helper to find the previous migration version
  def previous_version(current_version)
    versions = ActiveRecord::Migrator.get_all_versions.sort
    index = versions.index(current_version)
    return 0 if index == 0
    versions[index - 1]
  end
end 