import { Title, Text, Stack, Card } from '@mantine/core';

const ContactPageHeader = () => {
  return (
    <Stack align={'center'} gap={'xl'}>
      <Title size={'2rem'}>
        Solution: <span style={HEADER_STYLE}>Contact Form</span>
      </Title>

      <Card withBorder p={'lg'} radius={'md'} maw={600}>
        <Stack gap={'md'}>
          <Title order={3} ta={'center'}>
            What's happening here?
          </Title>
          <Text c={'dimmed'} ta={'center'}>
            This contact form demonstrates a complete serverless communication pipeline.
            When you submit your message, it's processed through AWS Lambda functions,
            stored securely in DynamoDB, and automatically sends an email notification
            directly to my configured email address using AWS SES (Simple Email Service).
            I receive the message instantly in my inbox with all your contact details.
          </Text>
          <Text size={'sm'} c={'green'} ta={'center'} fs={'italic'}>
            Frontend → Lambda API → DynamoDB → SES Email → Configured Recipient
          </Text>
        </Stack>
      </Card>
    </Stack>
  );
};

export default ContactPageHeader;

/*━━━━━━━━━━━━ Styling ━━━━━━━━━━━━*/
const HEADER_STYLE: React.CSSProperties = {
  color: 'var(--mantine-color-blue-4)',
};
