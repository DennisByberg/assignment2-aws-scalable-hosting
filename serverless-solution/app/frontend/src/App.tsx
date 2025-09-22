import '@mantine/core/styles.css';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MantineProvider } from '@mantine/core';
import Header from './components/Header';
import HomePage from './pages/HomePage';
import ContactPage from './pages/ContactPage';

// Configure React Query client for API state management
// - retry: Automatically retry failed API requests up to 3 times before showing error
// - staleTime: Keep data fresh for 5 minutes before considering it stale and refetching
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 3,
      staleTime: 5 * 60 * 1000, // 5 minutes
    },
  },
});

const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <MantineProvider defaultColorScheme={'dark'}>
        <Router>
          <Header />
          <Routes>
            <Route path={'/'} element={<HomePage />} />
            <Route path={'/contact'} element={<ContactPage />} />
          </Routes>
        </Router>
      </MantineProvider>
    </QueryClientProvider>
  );
};

export default App;
