require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get signup" do
    get pages_signup_url
    assert_response :success
  end
end
