import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import { getDatabase, users } from '../db';
import { render } from '../templates';
import { AppContext } from '../types';

const app = new Hono<AppContext>();

// User profile
app.get('/:id/:username?', async (c) => {
  const userId = parseInt(c.req.param('id'));
  
  const db = getDatabase(c.env.DB);
  
  const user = await db.select()
    .from(users)
    .where(eq(users.id, userId))
    .limit(1);
  
  if (user.length === 0) {
    return c.text('User not found', 404);
  }
  
  const userData = user[0];
  
  return render(c, './user-profile.eta', {
    title: userData.username,
    profileUser: userData,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Members', url: '/members' },
      { title: userData.username },
    ],
  });
});

export default app;
