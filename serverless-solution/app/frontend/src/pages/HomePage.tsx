import { Container } from '@mantine/core';
import GreetingsDisplay from '../components/GreetingsDisplay';

const HomePage = () => {
  return (
    <Container size={'md'}>
      <GreetingsDisplay />
    </Container>
  );
};

export default HomePage;
