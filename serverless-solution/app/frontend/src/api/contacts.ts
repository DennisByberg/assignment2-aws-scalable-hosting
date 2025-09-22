const CONTACT_API_URL =
  import.meta.env.VITE_CONTACT_API_URL || 'http://localhost:3001/contact';

export interface ContactForm {
  name: string;
  email: string;
  msg: string;
}

// Submit contact form data to serverless backend
// Handles both development mock and production AWS Lambda endpoint
export const submitContactForm = async (formData: ContactForm): Promise<string> => {
  // Mock response for development environment
  if (import.meta.env.DEV && !import.meta.env.VITE_CONTACT_API_URL) {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    return 'Contact form submitted successfully (mock)';
  }

  const apiPayload = {
    name: formData.name,
    email: formData.email,
    message: formData.msg,
  };

  // Submit to AWS Lambda via API Gateway
  const response = await fetch(CONTACT_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(apiPayload),
  });

  if (!response.ok) throw new Error(`Failed to submit contact form: ${response.status}`);

  const responseText = await response.text();

  try {
    const jsonResponse = JSON.parse(responseText);
    return jsonResponse.message || jsonResponse;
  } catch {
    return responseText;
  }
};
