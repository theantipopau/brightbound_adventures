import { Hono } from 'hono';
import { eq, desc, sql } from 'drizzle-orm';
import { getDatabase, categories, forums, users, threads } from '../db';
import { render } from '../templates';
import { AppContext } from '../types';

const router = new Hono<AppContext>();

// Forum index
router.get('/', async (c) => {
  const db = getDatabase(c.env.DB);
  
  // Get all categories
  const allCategories = await db.select().from(categories).orderBy(categories.sortOrder);
  
  // Get all forums with last post user info
  const allForums = await db.select({
    id: forums.id,
    categoryId: forums.categoryId,
    title: forums.title,
    description: forums.description,
    sortOrder: forums.sortOrder,
    threadCount: forums.threadCount,
    postCount: forums.postCount,
    lastPostAt: forums.lastPostAt,
    lastPostUserId: forums.lastPostUserId,
  })
  .from(forums)
  .orderBy(forums.sortOrder);
  
  // Fetch last post users
  const forumsWithUsers = await Promise.all(
    allForums.map(async (forum) => {
      if (forum.lastPostUserId) {
        const user = await db.select({
          id: users.id,
          username: users.username,
        })
        .from(users)
        .where(eq(users.id, forum.lastPostUserId))
        .limit(1);
        
        return { ...forum, lastPostUser: user[0] || null };
      }
      return { ...forum, lastPostUser: null };
    })
  );
  
  // Get online users (active in last 15 minutes)
  const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000);
  const onlineUsersList = await db.select({
    id: users.id,
    username: users.username,
  })
  .from(users)
  .where(sql`${users.lastActiveAt} > ${fifteenMinutesAgo.getTime()}`)
  .limit(50);
  
  // Get stats
  const totalThreadsResult = await db.select({ count: sql<number>`count(*)` }).from(threads);
  const totalMembersResult = await db.select({ count: sql<number>`count(*)` }).from(users);
  
  const newestMember = await db.select({
    id: users.id,
    username: users.username,
  })
  .from(users)
  .orderBy(desc(users.createdAt))
  .limit(1);
  
  const totalPosts = allForums.reduce((sum, f) => sum + (f.postCount || 0), 0);
  
  return render(c, './index.eta', {
    title: 'Forum Home',
    categories: allCategories,
    forums: forumsWithUsers,
    onlineUsers: {
      count: onlineUsersList.length,
      users: onlineUsersList,
    },
    stats: {
      totalThreads: totalThreadsResult[0]?.count || 0,
      totalPosts,
      totalMembers: totalMembersResult[0]?.count || 0,
      newestMember: newestMember[0] || null,
    },
    breadcrumbs: [],
  });
});

export default router;
