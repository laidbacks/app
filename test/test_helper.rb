ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "support/database_test_helper"
require_relative "support/authentication_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Include the database test helper
    include DatabaseTestHelper

    # Add more helper methods to be used by all tests here...
  end
end

# Include authentication helpers for integration tests
class ActionDispatch::IntegrationTest
  include AuthenticationHelper
end
