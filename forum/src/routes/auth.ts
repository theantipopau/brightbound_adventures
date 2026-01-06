import { Hono } from 'hono';
import { eq, or } from 'drizzle-orm';
import { getDatabase, users } from '../db';
import { render } from '../templates';
import { hashPassword, verifyPassword } from '../security/crypto';
import { createSession, setSessionCookie, deleteSession, clearSessionCookie } from '../security/session';
import { rateLimitMiddleware } from '../security/ratelimit';
import { AppContext } from '../types';

const app = new Hono<AppContext>();

// Login page
app.get('/login', async (c) => {
  const redirect = c.req.query('redirect') || '/';
  return render(c, './login.eta', {
    title: 'Login',
    redirect,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Login' },
    ],
  });
});

// Login handler
app.post('/login', rateLimitMiddleware('login'), async (c) => {
  const formData = await c.req.formData();
  const username = formData.get('username')?.toString() || '';
  const password = formData.get('password')?.toString() || '';
  const redirect = formData.get('redirect')?.toString() || '/';
  
  if (!username || !password) {
    return render(c, './login.eta', {
      title: 'Login',
      error: 'Username and password are required',
      redirect,
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Login' },
      ],
    });
  }
  
  const db = getDatabase(c.env.DB);
  
  // Find user by username or email
  const user = await db.select()
    .from(users)
    .where(or(eq(users.username, username), eq(users.email, username)))
    .limit(1);
  
  if (user.length === 0) {
    return render(c, './login.eta', {
      title: 'Login',
      error: 'Invalid username or password',
      redirect,
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Login' },
      ],
    });
  }
  
  const foundUser = user[0];
  
  // Check if banned
  if (foundUser.isBanned) {
    return render(c, './login.eta', {
      title: 'Login',
      error: 'Your account has been banned',
      redirect,
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Login' },
      ],
    });
  }
  
  // Verify password
  const isValid = await verifyPassword(foundUser.passwordHash, password);
  
  if (!isValid) {
    return render(c, './login.eta', {
      title: 'Login',
      error: 'Invalid username or password',
      redirect,
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Login' },
      ],
    });
  }
  
  // Update last active
  await db.update(users)
    .set({ lastActiveAt: new Date() })
    .where(eq(users.id, foundUser.id));
  
  // Create session
  const sessionId = await createSession(c, foundUser.id, foundUser.username, foundUser.role);
  setSessionCookie(c, sessionId);
  
  return c.redirect(redirect);
});

// Register page
app.get('/register', async (c) => {
  return render(c, './register.eta', {
    title: 'Register',
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Register' },
    ],
  });
});

// Register handler
app.post('/register', rateLimitMiddleware('register'), async (c) => {
  const formData = await c.req.formData();
  const username = formData.get('username')?.toString() || '';
  const email = formData.get('email')?.toString() || '';
  const password = formData.get('password')?.toString() || '';
  const passwordConfirm = formData.get('password_confirm')?.toString() || '';
  
  // Validation
  if (!username || !email || !password || !passwordConfirm) {
    return render(c, './register.eta', {
      title: 'Register',
      error: 'All fields are required',
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Register' },
      ],
    });
  }
  
  if (!/^[a-zA-Z0-9_]{3,20}$/.test(username)) {
    return render(c, './register.eta', {
      title: 'Register',
      error: 'Username must be 3-20 characters, letters, numbers, and underscore only',
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Register' },
      ],
    });
  }
  
  if (password.length < 8) {
    return render(c, './register.eta', {
      title: 'Register',
      error: 'Password must be at least 8 characters',
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Register' },
      ],
    });
  }
  
  if (password !== passwordConfirm) {
    return render(c, './register.eta', {
      title: 'Register',
      error: 'Passwords do not match',
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Register' },
      ],
    });
  }
  
  const db = getDatabase(c.env.DB);
  
  // Check if username or email exists
  const existing = await db.select()
    .from(users)
    .where(or(eq(users.username, username), eq(users.email, email)))
    .limit(1);
  
  if (existing.length > 0) {
    return render(c, './register.eta', {
      title: 'Register',
      error: 'Username or email already exists',
      breadcrumbs: [
        { title: 'Home', url: '/' },
        { title: 'Register' },
      ],
    });
  }
  
  // Hash password
  const passwordHash = await hashPassword(password);
  
  // Create user
  const result = await db.insert(users).values({
    username,
    email,
    passwordHash,
    role: 'member',
    isVerified: false,
    isBanned: false,
    createdAt: new Date(),
    lastActiveAt: new Date(),
  });
  
  // Create session
  const userId = (result as any).lastInsertRowid as number;
  const sessionId = await createSession(c, userId, username, 'member');
  setSessionCookie(c, sessionId);
  
  return c.redirect('/');
});

// Logout
app.get('/logout', async (c) => {
  await deleteSession(c);
  clearSessionCookie(c);
  return c.redirect('/');
});

export default app;
