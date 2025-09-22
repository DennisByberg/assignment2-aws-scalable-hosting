interface Greeting {
  greeting: string;
}

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

export const fetchGreeting = async (): Promise<Greeting[]> => {
  // Development mock - simulates API response when no backend is configured
  if (import.meta.env.DEV && !import.meta.env.VITE_API_URL) {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    return [
      { greeting: 'Hello from Local Mock!' },
      { greeting: 'Hej från Lokal Mock!' },
      { greeting: 'Welcome to Development!' },
    ];
  }

  const response = await fetch(API_BASE_URL);

  if (!response.ok) throw new Error(`Failed to fetch greetings: ${response.status}`);

  const data = await response.json();

  // Handle empty response from Lambda/DynamoDB
  if (Array.isArray(data) && data.length === 0) {
    throw new Error('No greetings found in database');
  }

  // Transform DynamoDB raw format if needed (Items array)
  if (data.Items && Array.isArray(data.Items)) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return data.Items.map((item: any) => ({
      greeting: item.greeting?.S || item.greeting || 'Unknown greeting',
    }));
  }

  // Handle standard array response from Lambda
  if (Array.isArray(data)) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return data.map((item: any) => ({
      greeting: item.greeting || item.toString(),
    }));
  }

  // Handle single greeting object
  if (data.greeting) return [{ greeting: data.greeting }];

  // Handle plain string response
  if (typeof data === 'string') return [{ greeting: data }];

  // Fallback for unexpected response format
  throw new Error('Unexpected API response format');
};
