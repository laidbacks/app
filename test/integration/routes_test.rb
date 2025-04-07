require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
  test "progress route is defined correctly" do
    assert_routing(
      { path: "/progress", method: :get },
      { controller: "progress", action: "index" }
    )
  end

  test "progress route is aliased properly" do
    # Test that the progress_path helper works
    assert_equal "/progress", progress_path
  end
end
