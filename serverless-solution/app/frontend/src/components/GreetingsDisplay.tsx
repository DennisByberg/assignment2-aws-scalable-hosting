import {
  Stack,
  Center,
  Loader,
  Alert,
  Button,
  Paper,
  Text,
  Card,
  Title,
} from '@mantine/core';
import { useQuery } from '@tanstack/react-query';
import { TypeAnimation } from 'react-type-animation';
import { fetchGreeting } from '../api/greetings';

interface Greeting {
  greeting: string;
}

const GreetingsDisplay = () => {
  const {
    data: greetings,
    isLoading,
    error,
    refetch,
  } = useQuery({
    queryKey: ['greeting'],
    queryFn: fetchGreeting,
  });

  const createAnimationSequence = (): (string | number)[] => {
    if (!greetings || !Array.isArray(greetings) || greetings.length === 0) {
      return ['Hello Local World', 1500, 'Hej Lokala Världen', 1500];
    }

    const sequence: (string | number)[] = [];
    greetings.forEach((item: Greeting) => {
      if (item && item.greeting) {
        sequence.push(item.greeting, 1500);
      }
    });

    if (sequence.length === 0) {
      return ['Hello World', 1500];
    }

    return sequence;
  };

  return (
    <Stack align={'center'} gap={'xl'}>
      <Stack align={'center'} gap={'lg'} ta={'center'}>
        <Title size={'2rem'}>
          Solution: <span style={GREETINGS_STYLE}>Greetings</span>
        </Title>
      </Stack>

      {/* What's happening explanation */}
      <Card withBorder p={'lg'} radius={'md'} maw={600}>
        <Stack gap={'md'}>
          <Title order={3} ta={'center'}>
            What's happening here?
          </Title>
          <Text c={'dimmed'} ta={'center'}>
            This application demonstrates a complete serverless data flow. The animated
            greetings below are fetched in real-time from an AWS DynamoDB database through
            a Lambda API endpoint. Each greeting stored in the database appears in the
            typewriter animation, showcasing how data flows from cloud storage to your
            browser.
          </Text>
          <Text size={'sm'} c={'green'} ta={'center'} fs={'italic'}>
            Backend: DynamoDB → Lambda API → Frontend
          </Text>
        </Stack>
      </Card>

      <Paper>
        <Stack>
          {isLoading && (
            <Center>
              <Stack align={'center'}>
                <Loader size={'lg'} />
                <Text c={'dimmed'}>Loading greetings from DynamoDB...</Text>
              </Stack>
            </Center>
          )}

          {error && (
            <Alert variant={'light'} color={'red'} title={'Connection Failed'}>
              <Stack gap={'md'}>
                <Text c={'dimmed'}>Unable to fetch greetings from the AWS database</Text>
                <Button
                  variant={'outline'}
                  color={'blue'}
                  size={'sm'}
                  onClick={() => refetch()}
                >
                  Try Again
                </Button>
              </Stack>
            </Alert>
          )}

          {greetings && !isLoading && (
            <Stack align={'center'} gap={'md'}>
              <TypeAnimation
                key={greetings.length}
                sequence={createAnimationSequence()}
                wrapper={'h1'}
                speed={50}
                repeat={Infinity}
              />
              <Text size={'sm'} c={'dimmed'}>
                Showing {greetings.length} greetings from DynamoDB
              </Text>
            </Stack>
          )}
        </Stack>
      </Paper>
    </Stack>
  );
};

export default GreetingsDisplay;

/*━━━━━━━━━━━━ Styling ━━━━━━━━━━━━*/
const GREETINGS_STYLE: React.CSSProperties = {
  color: 'var(--mantine-color-blue-4)',
};
