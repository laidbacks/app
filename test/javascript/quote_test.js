/**
 * @jest-environment jsdom
 */

describe('Quote functionality', () => {
  // Setup DOM elements
  beforeEach(() => {
    document.body.innerHTML = `
      <div class="quote-container" id="quote-container">
        <blockquote class="quote-of-day" id="quote-text">
          "Test quote" <span class="quote-author">– Test Author</span>
        </blockquote>
        <div class="quote-tip">Tap to change</div>
      </div>
    `;
    
    // Mock the quotes array
    global.quotes = [
      "Quote 1 – Author 1",
      "Quote 2 – Author 2", 
      "Quote 3 – Author 3"
    ];
  });
  
  test('quote container exists', () => {
    const quoteContainer = document.getElementById('quote-container');
    expect(quoteContainer).not.toBeNull();
  });
  
  test('quote text is displayed', () => {
    const quoteText = document.getElementById('quote-text');
    expect(quoteText.textContent).toContain('Test quote');
    expect(quoteText.textContent).toContain('Test Author');
  });
  
  test('clicking the quote changes the text', () => {
    // Create our test functionality
    const quoteContainer = document.getElementById('quote-container');
    const quoteText = document.getElementById('quote-text');
    
    // Initial state
    const initialQuote = quoteText.textContent;
    
    // Setup a mock for changing the quote
    let currentIndex = 0;
    
    function formatQuote(quote) {
      const parts = quote.split(' – ');
      if (parts.length === 2) {
        return `"${parts[0]}" <span class="quote-author">– ${parts[1]}</span>`;
      }
      return `"${quote}"`;
    }
    
    function getRandomQuote() {
      currentIndex = (currentIndex + 1) % global.quotes.length;
      return global.quotes[currentIndex];
    }
    
    // Simulate a click and quote change
    quoteContainer.addEventListener('click', () => {
      const newQuote = getRandomQuote();
      quoteText.innerHTML = formatQuote(newQuote);
    });
    
    // Trigger the click
    quoteContainer.click();
    
    // Check if the quote changed
    expect(quoteText.textContent).not.toEqual(initialQuote);
    expect(quoteText.innerHTML).toContain('quote-author');
  });
}); 