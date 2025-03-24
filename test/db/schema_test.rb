require "test_helper"

class SchemaTest < ActiveSupport::TestCase
  # Tests related to database schema and migrations
  
  # Test that the schema is up to date with migrations
  test "schema is up to date" do
    migration_paths = ActiveRecord::Migrator.migrations_paths
    
    # Get the current schema version from schema.rb
    schema_version = ActiveRecord::Migrator.current_version
    
    # Get the latest migration version
    migrations = ActiveRecord::MigrationContext.new(
      migration_paths, 
      ActiveRecord::SchemaMigration
    ).migrations
    latest_migration_version = migrations.empty? ? 0 : migrations.max_by(&:version).version
    
    # Schema should be at the latest migration version
    assert_equal latest_migration_version, schema_version,
      "Schema version (#{schema_version}) is not at the latest migration (#{latest_migration_version}). Run bin/rails db:migrate."
  end
  
  # Test that required tables exist
  test "required tables exist" do
    # Get list of tables from database
    connection = ActiveRecord::Base.connection
    tables = connection.tables
    
    # Check that essential tables exist
    assert_includes tables, "users", "Users table doesn't exist"
    assert_includes tables, "schema_migrations", "Schema migrations table doesn't exist"
    assert_includes tables, "ar_internal_metadata", "AR internal metadata table doesn't exist"
  end
  
  # Test that the users table has required columns
  test "users table has required columns" do
    # Get column information for users table
    connection = ActiveRecord::Base.connection
    columns = connection.columns("users").map(&:name)
    
    # Check that essential columns exist
    assert_includes columns, "id", "Users table is missing id column"
    assert_includes columns, "username", "Users table is missing username column"
    assert_includes columns, "password_digest", "Users table is missing password_digest column"
    assert_includes columns, "created_at", "Users table is missing created_at column"
    assert_includes columns, "updated_at", "Users table is missing updated_at column"
  end
  
  # Verify column types and properties
  test "users table has correct column types" do
    connection = ActiveRecord::Base.connection
    
    # Check column types
    id_column = connection.columns("users").find { |c| c.name == "id" }
    username_column = connection.columns("users").find { |c| c.name == "username" }
    password_digest_column = connection.columns("users").find { |c| c.name == "password_digest" }
    
    assert_equal :integer, id_column.type, "id column should be an integer"
    assert_equal :string, username_column.type, "username column should be a string"
    assert_equal :string, password_digest_column.type, "password_digest column should be a string"
    
    # In SQLite you can't always check null constraints directly,
    # but in PostgreSQL or MySQL you could check column.null
  end
  
  # Test for indexes on the users table
  test "users table has required indexes" do
    connection = ActiveRecord::Base.connection
    indexes = connection.indexes("users")
    
    # Check if an index exists that includes the username column
    username_indexed = indexes.any? do |index|
      index.columns.include?("username")
    end
    
    # If no index exists, let's see what indexes are available for debugging
    unless username_indexed
      available_indexes = indexes.map { |i| "#{i.name} on (#{i.columns.join(', ')})" }.join(", ")
      puts "Available indexes: #{available_indexes}"
    end
    
    assert username_indexed, "No index found on username column"
    
    # Only test uniqueness if an index exists to avoid nil error
    if username_indexed
      username_index = indexes.find { |i| i.columns.include?("username") }
      assert username_index.unique, "Index on username should be unique"
    end
  end
end 