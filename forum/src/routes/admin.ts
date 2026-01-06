import { Hono } from 'hono';
import { getDatabase, categories, forums, users } from '../db';
import { render } from '../templates';
import { requireRole } from '../middleware/auth';
import { eq, sql } from 'drizzle-orm';
import { AppContext } from '../types';

const app = new Hono<AppContext>();

// All admin routes require admin role
app.use('*', requireRole('admin'));

// Admin dashboard
app.get('/', async (c) => {
  const db = getDatabase(c.env.DB);
  
  return render(c, './admin-dashboard.eta', {
    title: 'Admin Dashboard',
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Admin' },
    ],
  });
});

// Manage categories
app.get('/categories', async (c) => {
  const db = getDatabase(c.env.DB);
  
  const allCategories = await db.select().from(categories).orderBy(categories.sortOrder);
  
  return render(c, './admin-categories.eta', {
    title: 'Manage Categories',
    categories: allCategories,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Admin', url: '/admin' },
      { title: 'Categories' },
    ],
  });
});

// Manage forums
app.get('/forums', async (c) => {
  const db = getDatabase(c.env.DB);
  
  const allForums = await db.select().from(forums).orderBy(forums.sortOrder);
  const allCategories = await db.select().from(categories).orderBy(categories.sortOrder);
  
  return render(c, './admin-forums.eta', {
    title: 'Manage Forums',
    forums: allForums,
    categories: allCategories,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Admin', url: '/admin' },
      { title: 'Forums' },
    ],
  });
});

// Manage users
app.get('/users', async (c) => {
  const db = getDatabase(c.env.DB);
  
  const allUsers = await db.select().from(users).orderBy(users.createdAt).limit(100);
  
  return render(c, './admin-users.eta', {
    title: 'Manage Users',
    users: allUsers,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Admin', url: '/admin' },
      { title: 'Users' },
    ],
  });
});

export default app;
