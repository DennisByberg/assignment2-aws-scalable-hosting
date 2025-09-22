import { TextInput, Textarea, Button, Stack, Alert, Card } from '@mantine/core';
import { useForm } from '@mantine/form';
import { useMutation } from '@tanstack/react-query';
import { useState } from 'react';
import { submitContactForm, type ContactForm as ContactFormData } from '../api/contacts';

interface ContactFormProps {
  onSuccess?: () => void;
}

const ContactForm = ({ onSuccess }: ContactFormProps) => {
  const [showSuccess, setShowSuccess] = useState(false);

  const form = useForm<ContactFormData>({
    initialValues: {
      name: '',
      email: '',
      msg: '',
    },
    validate: {
      name: (value) =>
        value.trim().length < 2 ? 'Name must be at least 2 characters' : null,
      email: (value) => (/^\S+@\S+$/.test(value) ? null : 'Invalid email'),
      msg: (value) =>
        value.trim().length < 10 ? 'Message must be at least 10 characters' : null,
    },
  });

  const mutation = useMutation({
    mutationFn: submitContactForm,
    onSuccess: () => {
      setShowSuccess(true);
      form.reset();
      onSuccess?.();
      setTimeout(() => setShowSuccess(false), 5000);
    },
  });

  const handleSubmit = (values: ContactFormData) => {
    mutation.mutate(values);
  };

  return (
    <Stack align={'center'} w={'100%'}>
      <Card
        withBorder
        p={'xl'}
        radius={'md'}
        maw={500}
        w={'100%'}
        style={FORM_CONTAINER_STYLE}
      >
        <Stack gap={'lg'}>
          {showSuccess && (
            <Alert variant={'light'} color={'green'} title={'Message Sent!'}>
              Thank you for your message. I'll get back to you soon!
            </Alert>
          )}

          {mutation.error && (
            <Alert variant={'light'} color={'red'} title={'Error'}>
              Failed to send message. Please try again.
            </Alert>
          )}

          <form onSubmit={form.onSubmit(handleSubmit)}>
            <Stack gap={'md'}>
              <TextInput
                label={'Name'}
                placeholder={'Your full name'}
                required
                {...form.getInputProps('name')}
              />

              <TextInput
                label={'Email'}
                placeholder={'your.email@example.com'}
                required
                {...form.getInputProps('email')}
              />

              <Textarea
                label={'Message'}
                placeholder={'Tell us about your project or ask any questions...'}
                required
                minRows={4}
                {...form.getInputProps('msg')}
              />

              <Button
                type={'submit'}
                loading={mutation.isPending}
                disabled={!form.isValid()}
                size={'md'}
                mt={'md'}
              >
                Send Message
              </Button>
            </Stack>
          </form>
        </Stack>
      </Card>
    </Stack>
  );
};

export default ContactForm;

/*━━━━━━━━━━━━ Styling ━━━━━━━━━━━━*/
const FORM_CONTAINER_STYLE = {
  maxWidth: '500px',
  width: '100%',
};
