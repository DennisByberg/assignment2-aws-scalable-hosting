import { Container, Stack } from '@mantine/core';
import ContactPageHeader from '../components/ContactPageHeader';
import ContactForm from '../components/ContactForm';

const ContactPage = () => {
  return (
    <Container size={'md'}>
      <Stack gap={'xl'}>
        <ContactPageHeader />
        <ContactForm />
      </Stack>
    </Container>
  );
};

export default ContactPage;
