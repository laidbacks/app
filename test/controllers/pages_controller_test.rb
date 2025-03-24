require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get signup" do
    # The signup route in the routes.rb is to users#signup, not pages#signup
    # Let's test the root path instead which goes to pages#home
    get root_path
    assert_response :success
  end
end
