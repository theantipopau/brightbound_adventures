import { Hono } from 'hono';
import { eq, or, and, desc } from 'drizzle-orm';
import { getDatabase, privateMessages, users } from '../db';
import { render } from '../templates';
import { requireAuth } from '../middleware/auth';
import { parseBBCode, validateBBCode } from '../bbcode/parser';
import { rateLimitMiddleware } from '../security/ratelimit';
import { AppContext } from '../types';

const app = new Hono<AppContext>();

// Inbox
app.get('/', requireAuth, async (c) => {
  const user = c.get('user');
  const db = getDatabase(c.env.DB);
  
  const messages = await db.select({
    id: privateMessages.id,
    fromUserId: privateMessages.fromUserId,
    subject: privateMessages.subject,
    createdAt: privateMessages.createdAt,
    isRead: privateMessages.isRead,
  })
  .from(privateMessages)
  .where(and(
    eq(privateMessages.toUserId, user.id),
    eq(privateMessages.recipientDeleted, false)
  ))
  .orderBy(desc(privateMessages.createdAt));
  
  const messagesWithSenders = await Promise.all(
    messages.map(async (msg) => {
      const sender = await db.select({ id: users.id, username: users.username })
        .from(users)
        .where(eq(users.id, msg.fromUserId))
        .limit(1);
      return { ...msg, sender: sender[0] };
    })
  );
  
  return render(c, './messages-inbox.eta', {
    title: 'Inbox',
    messages: messagesWithSenders,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Messages' },
    ],
  });
});

// Sent messages
app.get('/sent', requireAuth, async (c) => {
  const user = c.get('user');
  const db = getDatabase(c.env.DB);
  
  const messages = await db.select()
    .from(privateMessages)
    .where(and(
      eq(privateMessages.fromUserId, user.id),
      eq(privateMessages.senderDeleted, false)
    ))
    .orderBy(desc(privateMessages.createdAt));
  
  return render(c, './messages-sent.eta', {
    title: 'Sent Messages',
    messages,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Messages', url: '/messages' },
      { title: 'Sent' },
    ],
  });
});

// Compose message
app.get('/compose', requireAuth, async (c) => {
  const toUsername = c.req.query('to') || '';
  
  return render(c, './messages-compose.eta', {
    title: 'Compose Message',
    toUsername,
    breadcrumbs: [
      { title: 'Home', url: '/' },
      { title: 'Messages', url: '/messages' },
      { title: 'Compose' },
    ],
  });
});

app.post('/compose', requireAuth, rateLimitMiddleware('pm'), async (c) => {
  const user = c.get('user');
  const formData = await c.req.formData();
  const toUsername = formData.get('to')?.toString() || '';
  const subject = formData.get('subject')?.toString() || '';
  const body = formData.get('body')?.toString() || '';
  
  if (!toUsername || !subject || !body) {
    return c.text('All fields required', 400);
  }
  
  const validation = validateBBCode(body);
  if (!validation.valid) {
    return c.text(`BBCode error: ${validation.error}`, 400);
  }
  
  const db = getDatabase(c.env.DB);
  
  const recipient = await db.select()
    .from(users)
    .where(eq(users.username, toUsername))
    .limit(1);
  
  if (recipient.length === 0) {
    return c.text('Recipient not found', 404);
  }
  
  const bodyHtml = parseBBCode(body);
  
  await db.insert(privateMessages).values({
    fromUserId: user.id,
    toUserId: recipient[0].id,
    subject,
    bodyRaw: body,
    bodyHtml,
    createdAt: new Date(),
    isRead: false,
    senderDeleted: false,
    recipientDeleted: false,
  });
  
  return c.redirect('/messages/sent');
});

export default app;
