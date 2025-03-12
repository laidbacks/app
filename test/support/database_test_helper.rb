module DatabaseTestHelper
  # Create a temporary database and run the given block with a connection to it
  def with_temporary_database(db_name = "temp_test_db")
    # Create a new database connection for testing
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    test_db_path = Rails.root.join("tmp", "#{db_name}.sqlite3")
    test_config = config.configuration_hash.merge(database: test_db_path)
    
    # Ensure clean state
    FileUtils.rm_f(test_db_path)
    
    # Store original connection
    original_connection = ActiveRecord::Base.connection_pool
    
    begin
      # Connect to the test database
      ActiveRecord::Base.establish_connection(test_config)
      
      # Run migrations
      ActiveRecord::Tasks::DatabaseTasks.migrate
      
      # Yield to the block
      yield
    ensure
      # Clean up
      ActiveRecord::Base.connection.disconnect!
      
      # Remove temporary DB file
      FileUtils.rm_f(test_db_path)
      
      # Restore original connection
      ActiveRecord::Base.connection_handler.establish_connection(
        original_connection.spec.to_hash, 
        original_connection.role
      )
    end
  end
  
  # Test that indices exist on the specified table and columns
  def assert_index_exists(table, columns, options = {})
    columns = [columns] unless columns.is_a?(Array)
    
    connection = ActiveRecord::Base.connection
    indices = connection.indexes(table)
    
    # Find an index that covers our columns
    matching_index = indices.find do |index|
      index_columns = index.columns
      
      # Check if all required columns are covered by this index
      columns.all? { |col| index_columns.include?(col.to_s) }
    end
    
    message = options[:message] || "No index found on #{table} for column(s) #{columns.join(', ')}"
    assert_not_nil matching_index, message
    
    # If uniqueness is specified, check it
    if options.key?(:unique)
      assert_equal options[:unique], matching_index.unique,
        "Index on #{table} #{columns.join(', ')} has wrong uniqueness"
    end
  end
  
  # Assert that a foreign key exists
  def assert_foreign_key_exists(from_table, to_table, options = {})
    connection = ActiveRecord::Base.connection
    
    # Only proceed if the database adapter supports this
    if connection.respond_to?(:foreign_keys)
      foreign_keys = connection.foreign_keys(from_table)
      column = options[:column] || "#{to_table.to_s.singularize}_id"
      
      matching_fk = foreign_keys.find do |fk|
        fk.to_table.to_s == to_table.to_s && 
        (!options[:column] || fk.column.to_s == column.to_s)
      end
      
      message = options[:message] || 
                "No foreign key found on #{from_table} referencing #{to_table}"
      assert_not_nil matching_fk, message
      
      # Check on_delete behavior if specified
      if options[:on_delete]
        assert_equal options[:on_delete].to_s, matching_fk.on_delete,
          "Foreign key on #{from_table} has wrong on_delete behavior"
      end
    else
      skip "Database adapter doesn't support foreign key introspection"
    end
  end
  
  # Execute SQL directly and return results
  def execute_sql(sql, binds = [])
    connection = ActiveRecord::Base.connection
    connection.exec_query(sql, "SQL", binds)
  end
  
  # Count the number of queries executed during a block
  def count_queries(&block)
    count = 0
    counter_fn = ->(_name, _started, _finished, _unique_id, payload) {
      # Skip CACHE queries
      count += 1 unless payload[:cached] || payload[:name] == "SCHEMA"
    }
    
    ActiveSupport::Notifications.subscribed(counter_fn, "sql.active_record", &block)
    
    count
  end
  
  # Assert a maximum number of queries
  def assert_max_queries(count, message = nil, &block)
    actual_count = count_queries(&block)
    message ||= "Expected maximum #{count} queries, but got #{actual_count}"
    assert actual_count <= count, message
  end
  
  # Test that a query hits an index (using EXPLAIN)
  # Note: This is database-specific and works best with MySQL or PostgreSQL
  def assert_query_uses_index(query, index_name = nil, binds = [])
    connection = ActiveRecord::Base.connection
    adapter_name = connection.adapter_name.downcase
    
    case adapter_name
    when /mysql/
      # For MySQL, use EXPLAIN
      explain = connection.execute("EXPLAIN #{query}").to_a
      
      if index_name
        key_column = explain.first["key"] || ""
        assert_equal index_name.to_s, key_column, 
          "Query didn't use the expected index '#{index_name}'"
      else
        key_column = explain.first["key"]
        assert_not_nil key_column, "Query didn't use any index"
        assert_not_equal "", key_column, "Query didn't use any index"
      end
      
    when /postgresql/
      # For PostgreSQL, use EXPLAIN
      explain = connection.execute("EXPLAIN #{query}").to_a.map { |r| r["QUERY PLAN"] }.join("\n")
      
      if index_name
        assert_match(/Index.*#{index_name}/i, explain, 
          "Query didn't use the expected index '#{index_name}'"
      else
        assert_match(/Index Scan/i, explain, "Query didn't use any index")
      end
      
    when /sqlite/
      # SQLite EXPLAIN is limited, just check it doesn't do a full table scan
      explain = connection.execute("EXPLAIN QUERY PLAN #{query}").to_a
      scan_info = explain.map { |row| row["detail"] }.join(" ")
      
      assert_not_match(/SCAN TABLE/i, scan_info, 
        "Query used a full table scan instead of an index")
      
    else
      skip "Unsupported database adapter for index usage testing: #{adapter_name}"
    end
  end
end 