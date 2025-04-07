require "application_system_test_case"

class QuoteInteractionsTest < ApplicationSystemTestCase
  setup do
    # Create a test user
    @user = User.create!(
      username: "testuser",
      password: "password123",
      password_confirmation: "password123"
    )
    
    # Log in the user
    visit login_path
    fill_in "Username", with: "testuser"
    fill_in "Password", with: "password123"
    click_button "Login"
  end

  test "quotes are displayed on the dashboard" do
    # Visit the dashboard
    visit root_path
    
    # Ensure the quote container exists
    assert_selector ".quote-container"
    assert_selector "#quote-text"
    
    # The quote should contain some text
    quote_text = find("#quote-text").text
    assert_not_empty quote_text
    
    # Store the original quote text
    original_quote = quote_text
    
    # Click on the quote to get a new quote
    find(".quote-container").click
    
    # Wait for the animation to complete (300ms fade out + 300ms fade in)
    sleep 0.7
    
    # Get the new quote text
    new_quote = find("#quote-text").text
    
    # Check if something changed (there's a small chance it might randomly select the same quote)
    if PagesController::QUOTES_COUNT > 1
      # Only run this assertion if we have more than one quote
      # because with just one quote, it would always be the same
      assert_not_equal original_quote, new_quote, "Quote didn't change after clicking"
    end
    
    # Test that the quote contains an author (indicated by the presence of a dash)
    author_element = find(".quote-author") rescue nil
    assert_not_nil author_element, "Author element is missing from the quote"
  end

  # test "visiting the index" do
  #   visit quote_interactions_url
  #
  #   assert_selector "h1", text: "QuoteInteraction"
  # end
end
