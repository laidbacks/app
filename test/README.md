# Database Testing in Rails

This directory contains various tests for the database layer of our Rails application.

## Test Files

- `models/user_fixture_test.rb` - Demonstrates working with fixtures
- `models/user_transaction_test.rb` - Demonstrates transaction behavior in tests
- `models/user_non_transactional_test.rb` - Shows tests that opt out of transactions
- `db/schema_test.rb` - Tests that the database schema is up to date

## Running Tests

### Preparing the Test Database

Ensure your test database is set up and migrations are up to date:

```bash
# Create the test database (if it doesn't exist)
bin/rails db:create RAILS_ENV=test

# Run migrations on the test database
bin/rails db:migrate RAILS_ENV=test

# If there were changes to existing migrations, rebuild the test database
bin/rails test:db
```

### Running All Tests

```bash
# Run all tests
bin/rails test
```

### Running Specific Test Files

```bash
# Run a specific test file
bin/rails test test/models/user_fixture_test.rb

# Run specific test method (line 10 in the file)
bin/rails test test/models/user_fixture_test.rb:10
```

### Running Tests by Type

```bash
# Run all model tests
bin/rails test:models

# Run all database schema tests
bin/rails test test/db
```

## Test Output

By default, Rails will show dots for passing tests and F for failing tests. 
For more verbose output, use the `-v` flag:

```bash
bin/rails test -v
```

## Notes on Test Transactions

Most tests in Rails run within a database transaction that is rolled back after the test completes.
This keeps tests isolated from each other. However, some tests may need to opt out of this behavior:

```ruby
class MyNonTransactionalTest < ActiveSupport::TestCase
  self.use_transactional_tests = false
  
  # cleanup is required in setup/teardown when not using transactions
end
```

## Fixtures

Fixtures are defined in the `test/fixtures` directory and automatically loaded before tests.
Access fixtures in your tests using the fixture name:

```ruby
# Get the admin user fixture
admin = users(:admin)

# Get multiple fixtures
users = users(:admin, :regular_user)
``` 