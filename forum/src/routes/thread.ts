import { Hono } from 'hono';
import { eq, desc, sql } from 'drizzle-orm';
import { getDatabase, threads, posts, users, forums, categories } from '../db';
import { render } from '../templates';
import { requireAuth } from '../middleware/auth';
import { parseBBCode, validateBBCode } from '../bbcode/parser';
import { rateLimitMiddleware } from '../security/ratelimit';
import { canModerate } from '../middleware/auth';
import { AppContext } from '../types';

const app = new Hono<AppContext>();

// View thread
app.get('/:id/:slug?', async (c) => {
  const threadId = parseInt(c.req.param('id'));
  const page = parseInt(c.req.query('page') || '1');
  const perPage = 20;
  
  const db = getDatabase(c.env.DB);
  
  // Get thread
  const thread = await db.select()
    .from(threads)
    .where(eq(threads.id, threadId))
    .limit(1);
  
  if (thread.length === 0) {
    return c.text('Thread not found', 404);
  }
  
  const threadData = thread[0];
  
  // Increment view count
  await db.update(threads)
    .set({ views: threadData.views + 1 })
    .where(eq(threads.id, threadId));
  
  // Get forum and category
  const forum = await db.select()
    .from(forums)
    .where(eq(forums.id, threadData.forumId))
    .limit(1);
  
  const category = forum.length > 0 
    ? await db.select().from(categories).where(eq(categories.id, forum[0].categoryId)).limit(1)
    : [];
  
  // Get posts with pagination
  const allPosts = await db.select()
    .from(posts)
    .where(eq(posts.threadId, threadId))
    .orderBy(posts.createdAt)
    .limit(perPage)
    .offset((page - 1) * perPage);
  
  // Get post authors with user info
  const postsWithAuthors = await Promise.all(
    allPosts.map(async (post) => {
      const author = await db.select({
        id: users.id,
        username: users.username,
        role: users.role,
        createdAt: users.createdAt,
        signature: users.signature,
      })
      .from(users)
      .where(eq(users.id, post.createdBy))
      .limit(1);
      
      // Get post count for author
      const postCountResult = await db.select({ count: sql<number>`count(*)` })
        .from(posts)
        .where(eq(posts.createdBy, post.createdBy));
      
      const authorData = author[0];
      let signatureHtml = null;
      if (authorData?.signature) {
        signatureHtml = parseBBCode(authorData.signature);
      }
      
      return {
        ...post,
        author: {
          ...authorData,
          postCount: postCountResult[0]?.count || 0,
          signatureHtml,
        },
      };
    })
  );
  
  // Count total posts
  const totalResult = await db.select({ count: sql<number>`count(*)` })
    .from(posts)
    .where(eq(posts.threadId, threadId));
  
  const totalPosts = totalResult[0]?.count || 0;
  const totalPages = Math.ceil(totalPosts / perPage);
  
  const user = c.get('user');
  
  return render(c, './thread.eta', {
    title: threadData.title,
    thread: threadData,
    posts: postsWithAuthors,
    forum: forum[0],
    canModerate: canModerate(user),
    pagination: {
      page,
      totalPages,
      totalPosts,
    },
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: category[0]?.title || 'Category' },
      { title: forum[0]?.title || 'Forum', url: `/forum/${forum[0]?.id}` },
      { title: threadData.title },
    ],
  });
});

// New thread page
app.get('/new', requireAuth, async (c) => {
  const forumId = parseInt(c.req.query('forumId') || '0');
  
  if (!forumId) {
    return c.text('Forum ID required', 400);
  }
  
  const db = getDatabase(c.env.DB);
  
  const forum = await db.select()
    .from(forums)
    .where(eq(forums.id, forumId))
    .limit(1);
  
  if (forum.length === 0) {
    return c.text('Forum not found', 404);
  }
  
  return render(c, './new-thread.eta', {
    title: 'New Topic',
    forum: forum[0],
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: forum[0].title, url: `/forum/${forum[0].id}` },
      { title: 'New Topic' },
    ],
  });
});

// Create new thread
app.post('/new', requireAuth, rateLimitMiddleware('post'), async (c) => {
  const formData = await c.req.formData();
  const forumId = parseInt(formData.get('forumId')?.toString() || '0');
  const title = formData.get('title')?.toString() || '';
  const content = formData.get('content')?.toString() || '';
  
  if (!forumId || !title || !content) {
    return c.text('Missing required fields', 400);
  }
  
  // Validate BBCode
  const validation = validateBBCode(content);
  if (!validation.valid) {
    return c.text(`BBCode error: ${validation.error}`, 400);
  }
  
  const db = getDatabase(c.env.DB);
  const user = c.get('user');
  
  // Create thread
  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  const now = new Date();
  
  const threadResult = await db.insert(threads).values({
    forumId,
    title,
    slug,
    createdBy: user.id,
    createdAt: now,
    updatedAt: now,
    isLocked: false,
    isSticky: false,
    views: 0,
    replyCount: 0,
    lastPostAt: now,
    lastPostBy: user.id,
  });
  
  const threadId = (threadResult as any).lastInsertRowid as number;
  
  // Create first post
  const contentHtml = parseBBCode(content);
  
  await db.insert(posts).values({
    threadId,
    createdBy: user.id,
    createdAt: now,
    contentRaw: content,
    contentHtml,
    isDeleted: false,
  });
  
  // Update forum stats
  await db.update(forums)
    .set({
      threadCount: sql`${forums.threadCount} + 1`,
      postCount: sql`${forums.postCount} + 1`,
      lastPostAt: now,
      lastPostUserId: user.id,
    })
    .where(eq(forums.id, forumId));
  
  return c.redirect(`/thread/${threadId}/${slug}`);
});

// Reply to thread
app.post('/:id/reply', requireAuth, rateLimitMiddleware('post'), async (c) => {
  const threadId = parseInt(c.req.param('id'));
  const formData = await c.req.formData();
  const content = formData.get('content')?.toString() || '';
  
  if (!content) {
    return c.text('Content required', 400);
  }
  
  // Validate BBCode
  const validation = validateBBCode(content);
  if (!validation.valid) {
    return c.text(`BBCode error: ${validation.error}`, 400);
  }
  
  const db = getDatabase(c.env.DB);
  const user = c.get('user');
  
  // Get thread
  const thread = await db.select()
    .from(threads)
    .where(eq(threads.id, threadId))
    .limit(1);
  
  if (thread.length === 0) {
    return c.text('Thread not found', 404);
  }
  
  const threadData = thread[0];
  
  if (threadData.isLocked && !canModerate(user)) {
    return c.text('Thread is locked', 403);
  }
  
  // Create post
  const now = new Date();
  const contentHtml = parseBBCode(content);
  
  await db.insert(posts).values({
    threadId,
    createdBy: user.id,
    createdAt: now,
    contentRaw: content,
    contentHtml,
    isDeleted: false,
  });
  
  // Update thread
  await db.update(threads)
    .set({
      replyCount: sql`${threads.replyCount} + 1`,
      lastPostAt: now,
      lastPostBy: user.id,
      updatedAt: now,
    })
    .where(eq(threads.id, threadId));
  
  // Update forum
  await db.update(forums)
    .set({
      postCount: sql`${forums.postCount} + 1`,
      lastPostAt: now,
      lastPostUserId: user.id,
    })
    .where(eq(forums.id, threadData.forumId));
  
  return c.redirect(`/thread/${threadId}/${threadData.slug}`);
});

// Thread moderation tools
app.post('/:id/tools', requireAuth, async (c) => {
  const threadId = parseInt(c.req.param('id'));
  const formData = await c.req.formData();
  const action = formData.get('action')?.toString();
  
  const user = c.get('user');
  if (!canModerate(user)) {
    return c.text('Forbidden', 403);
  }
  
  const db = getDatabase(c.env.DB);
  
  const thread = await db.select()
    .from(threads)
    .where(eq(threads.id, threadId))
    .limit(1);
  
  if (thread.length === 0) {
    return c.text('Thread not found', 404);
  }
  
  const threadData = thread[0];
  
  switch (action) {
    case 'lock':
      await db.update(threads).set({ isLocked: true }).where(eq(threads.id, threadId));
      break;
    case 'unlock':
      await db.update(threads).set({ isLocked: false }).where(eq(threads.id, threadId));
      break;
    case 'sticky':
      await db.update(threads).set({ isSticky: true }).where(eq(threads.id, threadId));
      break;
    case 'unsticky':
      await db.update(threads).set({ isSticky: false }).where(eq(threads.id, threadId));
      break;
    case 'delete':
      // Soft delete - mark all posts as deleted
      await db.update(posts)
        .set({ isDeleted: true, deletedBy: user.id, deletedAt: new Date() })
        .where(eq(posts.threadId, threadId));
      return c.redirect(`/forum/${threadData.forumId}`);
  }
  
  return c.redirect(`/thread/${threadId}/${threadData.slug}`);
});

export default app;
