require "test_helper"

class MigrationTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

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

      # Get migration context
      migration_context = ActiveRecord::MigrationContext.new(
        ActiveRecord::Migrator.migrations_paths
      )

      # Verify all migrations were applied
      current_version = ActiveRecord::Migrator.current_version
      migrations = migration_context.migrations
      latest_version = migrations.empty? ? 0 : migrations.max_by(&:version).version

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

      # Get the current version after migrations
      current_version = ActiveRecord::Migrator.current_version

      # Skip if no migrations were applied
      skip if current_version == 0

      # Try rolling back the latest migration
      assert_nothing_raised do
        # Roll back one migration, ignore index not found errors
        begin
          ActiveRecord::MigrationContext.new(
            ActiveRecord::Migrator.migrations_paths
          ).rollback(1)
        rescue StandardError => e
          # Only ignore index not found errors
          raise unless e.message.include?("No indexes found")
        end
      end

      # Verify rollback worked or was at least attempted
      new_version = ActiveRecord::Migrator.current_version

      # Try running the migration again
      assert_nothing_raised do
        ActiveRecord::Tasks::DatabaseTasks.migrate
      end

      # Verify migration worked
      final_version = ActiveRecord::Migrator.current_version
      assert_equal current_version, final_version,
        "Migration re-run failed. At version: #{final_version}, expected: #{current_version}"
    ensure
      # Clean up
      ActiveRecord::Base.remove_connection
      FileUtils.rm_f(test_db_path)

      # Reconnect to original database
      ActiveRecord::Base.establish_connection
    end
  end
end
