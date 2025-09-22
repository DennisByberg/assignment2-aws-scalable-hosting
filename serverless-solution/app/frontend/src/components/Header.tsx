import { Anchor, Box, Container, Group, Title, type CSSProperties } from '@mantine/core';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import viteLogo from '/vite.svg';

const links = [
  { link: '/', label: 'Home' },
  { link: '/contact', label: 'Contact' },
];

const Header = () => {
  const navigate = useNavigate();
  const [active, setActive] = useState(links[0].link);

  const items = links.map((link) => (
    <Anchor
      key={link.label}
      href={link.link}
      style={getLinkStyle(active === link.link)}
      onClick={(event) => {
        event.preventDefault();
        setActive(link.link);
        navigate(link.link);
      }}
    >
      {link.label}
    </Anchor>
  ));

  return (
    <Box
      component={'header'}
      mb={20}
      style={{ borderBottom: '1px solid var(--mantine-color-gray-8)' }}
    >
      <Container size={'md'} style={INNER_STYLE}>
        <Group
          gap={10}
          onClick={() => {
            setActive('/');
            navigate('/');
          }}
          style={{ cursor: 'pointer' }}
        >
          <img src={viteLogo} alt={'Vite logo'} height={32} width={32} />
          <Title size={'1.3rem'}>Serverless</Title>
        </Group>

        <Group gap={5}>{items}</Group>
      </Container>
    </Box>
  );
};

export default Header;

/*━━━━━━━━━━━━ Styling ━━━━━━━━━━━━*/
const INNER_STYLE: CSSProperties = {
  height: 56,
  display: 'flex',
  justifyContent: 'space-between',
  alignItems: 'center',
};

const getLinkStyle = (isActive: boolean): CSSProperties => ({
  lineHeight: 1,
  padding: '8px 12px',
  borderRadius: 'var(--mantine-radius-sm)',
  textDecoration: 'none',
  color: isActive
    ? 'var(--mantine-color-white)'
    : 'light-dark(var(--mantine-color-gray-7), var(--mantine-color-dark-0))',
  fontSize: 'var(--mantine-font-size-sm)',
  fontWeight: 500,
  backgroundColor: isActive ? 'var(--mantine-color-blue-filled)' : 'transparent',
});
