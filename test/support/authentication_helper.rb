module AuthenticationHelper
  # Sign in as a user for integration tests
  def sign_in_as(user, password = "password123")
    # Set the user_id in the session to simulate login
    post "/login", params: {
      username: user.username,
      password: password
    }

    # Follow the redirect if any
    follow_redirect! if response.redirect?
  end

  # Sign out current user
  def sign_out
    delete "/logout"
  end

  # Simulates setting a session directly for API tests
  def sign_in_api_as(user)
    # For API tests, we need to manually set the session in some cases
    # This doesn't always work in all test environments, but it's a good fallback
    post "/login", params: { username: user.username, password: "password123" }
  end
end
