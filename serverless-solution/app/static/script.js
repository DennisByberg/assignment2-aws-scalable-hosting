// Global state
let isLocalEnvironment = false;

// Initialize app
document.addEventListener('DOMContentLoaded', function () {
  checkEnvironment();
  setupNavigation();
  loadGreetings();
  setupContactForm();
});

// Check if running in local environment
function checkEnvironment() {
  isLocalEnvironment =
    !window.API_URLS.greetings ||
    !window.API_URLS.contact ||
    window.API_URLS.greetings.includes('localhost') ||
    window.API_URLS.contact.includes('localhost');

  if (isLocalEnvironment) {
    document.getElementById('local-warning').style.display = 'block';
    document.getElementById('submit-btn').disabled = true;
    document.getElementById('submit-btn').textContent = 'Disabled (Local Mode)';
  }
}

// Navigation setup
function setupNavigation() {
  const navLinks = document.querySelectorAll('.nav a');

  navLinks.forEach((link) => {
    link.addEventListener('click', function (e) {
      e.preventDefault();
      const page = this.dataset.page;

      navLinks.forEach((l) => l.classList.remove('active'));
      this.classList.add('active');

      document
        .querySelectorAll('.page-content')
        .forEach((p) => (p.style.display = 'none'));
      document.getElementById(page + '-page').style.display = 'block';
    });
  });
}

// Load greetings from API
async function loadGreetings() {
  if (!window.API_URLS.greetings) {
    displayLocalFallback();
    return;
  }

  try {
    const response = await fetch(window.API_URLS.greetings);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const greetingsData = await response.json();
    displayGreetings(greetingsData);
  } catch (error) {
    console.error('Error loading greetings:', error);
    displayLocalFallback();
  }
}

// Display local fallback when no AWS connection
function displayLocalFallback() {
  const mockData = [
    { greeting: 'Hello Local World' },
    { greeting: 'Hej Lokala Världen' },
  ];

  displayGreetings(mockData);

  document.getElementById('greetings-display').innerHTML += `
    <div class="message error" style="margin-top: 20px;">
      <strong>Local Development Mode</strong><br>
      No AWS API configured - showing local development data
    </div>
  `;
}

// Display greetings
function displayGreetings(greetingsData) {
  const display = document.getElementById('greetings-display');

  if (greetingsData && greetingsData.length > 0) {
    let greetingsList = '<ul class="greetings-list">';

    greetingsData.forEach((greeting) => {
      greetingsList += `<li class="greeting-item">${
        greeting.greeting || 'Hello World'
      }</li>`;
    });

    greetingsList += '</ul>';

    display.innerHTML = `
      ${greetingsList}
      <div class="greetings-info">
        Showing ${greetingsData.length} greetings from DynamoDB
      </div>
    `;
  } else {
    display.innerHTML = `
      <ul class="greetings-list">
        <li class="greeting-item">Hello Local World</li>
      </ul>
      <div class="greetings-info">No greetings available</div>
    `;
  }
}

// Setup contact form
function setupContactForm() {
  if (isLocalEnvironment) return;

  const form = document.getElementById('contact-form');

  form.addEventListener('submit', async function (e) {
    e.preventDefault();

    const formData = new FormData(form);
    const submitBtn = document.getElementById('submit-btn');
    const messagesDiv = document.getElementById('contact-messages');

    submitBtn.innerHTML = '<div class="spinner"></div>Sending...';
    submitBtn.disabled = true;

    try {
      const response = await fetch(window.API_URLS.contact, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: formData.get('name'),
          email: formData.get('email'),
          message: formData.get('message'),
        }),
      });

      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

      const result = await response.json();

      messagesDiv.innerHTML = `
        <div class="message success">
          <strong>Message Sent!</strong><br>
          ${result.message || 'Thank you for your message!'}
        </div>
      `;

      form.reset();

      setTimeout(() => {
        messagesDiv.innerHTML = '';
      }, 5000);
    } catch (error) {
      console.error('Contact form error:', error);
      messagesDiv.innerHTML = `
        <div class="message error">
          <strong>Error</strong><br>
          Failed to send message: ${error.message}
        </div>
      `;
    } finally {
      submitBtn.innerHTML = 'Send Message';
      submitBtn.disabled = false;
    }
  });
}
