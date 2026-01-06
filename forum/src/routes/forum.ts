import { Hono } from 'hono';
import { eq, desc, sql } from 'drizzle-orm';
import { getDatabase, forums, categories, threads, users } from '../db';
import { render } from '../templates';
import { AppContext } from '../types';

const app = new Hono<AppContext>();

// View forum
app.get('/:id/:slug?', async (c) => {
  const forumId = parseInt(c.req.param('id'));
  const page = parseInt(c.req.query('page') || '1');
  const perPage = 25;
  
  const db = getDatabase(c.env.DB);
  
  // Get forum
  const forum = await db.select()
    .from(forums)
    .where(eq(forums.id, forumId))
    .limit(1);
  
  if (forum.length === 0) {
    return c.text('Forum not found', 404);
  }
  
  const forumData = forum[0];
  
  // Get category for breadcrumbs
  const category = await db.select()
    .from(categories)
    .where(eq(categories.id, forumData.categoryId))
    .limit(1);
  
  // Get threads with pagination (sticky first)
  const allThreads = await db.select({
    id: threads.id,
    title: threads.title,
    slug: threads.slug,
    createdBy: threads.createdBy,
    createdAt: threads.createdAt,
    isLocked: threads.isLocked,
    isSticky: threads.isSticky,
    views: threads.views,
    replyCount: threads.replyCount,
    lastPostAt: threads.lastPostAt,
    lastPostBy: threads.lastPostBy,
  })
  .from(threads)
  .where(eq(threads.forumId, forumId))
  .orderBy(desc(threads.isSticky), desc(threads.lastPostAt))
  .limit(perPage)
  .offset((page - 1) * perPage);
  
  // Get author and last post user info
  const threadsWithUsers = await Promise.all(
    allThreads.map(async (thread) => {
      const author = await db.select({
        id: users.id,
        username: users.username,
      })
      .from(users)
      .where(eq(users.id, thread.createdBy))
      .limit(1);
      
      let lastPostUser = null;
      if (thread.lastPostBy) {
        const lastUser = await db.select({
          id: users.id,
          username: users.username,
        })
        .from(users)
        .where(eq(users.id, thread.lastPostBy))
        .limit(1);
        lastPostUser = lastUser[0] || null;
      }
      
      return {
        ...thread,
        author: author[0],
        lastPostUser,
      };
    })
  );
  
  // Count total threads
  const totalResult = await db.select({ count: sql<number>`count(*)` })
    .from(threads)
    .where(eq(threads.forumId, forumId));
  
  const totalThreads = totalResult[0]?.count || 0;
  const totalPages = Math.ceil(totalThreads / perPage);
  
  return render(c, './forum.eta', {
    title: forumData.title,
    forum: forumData,
    threads: threadsWithUsers,
    pagination: {
      page,
      totalPages,
      totalThreads,
    },
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: category[0]?.title || 'Category' },
      { title: forumData.title },
    ],
  });
});

export default app;
