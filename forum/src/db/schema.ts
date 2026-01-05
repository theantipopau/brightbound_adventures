import { sqliteTable, text, integer, index } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  username: text('username').notNull().unique(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  role: text('role').notNull().default('member'), // member, moderator, admin
  isVerified: integer('is_verified', { mode: 'boolean' }).notNull().default(false),
  isBanned: integer('is_banned', { mode: 'boolean' }).notNull().default(false),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  lastActiveAt: integer('last_active_at', { mode: 'timestamp' }),
  signature: text('signature'),
  settingsJson: text('settings_json'),
}, (table) => ({
  usernameIdx: index('username_idx').on(table.username),
  emailIdx: index('email_idx').on(table.email),
}));

export const categories = sqliteTable('categories', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  title: text('title').notNull(),
  sortOrder: integer('sort_order').notNull().default(0),
});

export const forums = sqliteTable('forums', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  categoryId: integer('category_id').notNull().references(() => categories.id),
  title: text('title').notNull(),
  description: text('description'),
  sortOrder: integer('sort_order').notNull().default(0),
  lastPostAt: integer('last_post_at', { mode: 'timestamp' }),
  lastPostUserId: integer('last_post_user_id'),
  threadCount: integer('thread_count').notNull().default(0),
  postCount: integer('post_count').notNull().default(0),
}, (table) => ({
  categoryIdx: index('forum_category_idx').on(table.categoryId),
}));

export const threads = sqliteTable('threads', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  forumId: integer('forum_id').notNull().references(() => forums.id),
  title: text('title').notNull(),
  slug: text('slug').notNull(),
  createdBy: integer('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
  isLocked: integer('is_locked', { mode: 'boolean' }).notNull().default(false),
  isSticky: integer('is_sticky', { mode: 'boolean' }).notNull().default(false),
  views: integer('views').notNull().default(0),
  replyCount: integer('reply_count').notNull().default(0),
  lastPostAt: integer('last_post_at', { mode: 'timestamp' }).notNull(),
  lastPostBy: integer('last_post_by').references(() => users.id),
}, (table) => ({
  forumIdx: index('thread_forum_idx').on(table.forumId),
  lastPostIdx: index('thread_last_post_idx').on(table.lastPostAt),
}));

export const posts = sqliteTable('posts', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  threadId: integer('thread_id').notNull().references(() => threads.id),
  createdBy: integer('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }),
  contentRaw: text('content_raw').notNull(),
  contentHtml: text('content_html').notNull(),
  isDeleted: integer('is_deleted', { mode: 'boolean' }).notNull().default(false),
  deletedBy: integer('deleted_by').references(() => users.id),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
}, (table) => ({
  threadIdx: index('post_thread_idx').on(table.threadId),
  createdIdx: index('post_created_idx').on(table.createdAt),
}));

export const postEdits = sqliteTable('post_edits', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  postId: integer('post_id').notNull().references(() => posts.id),
  editedBy: integer('edited_by').notNull().references(() => users.id),
  editedAt: integer('edited_at', { mode: 'timestamp' }).notNull(),
  previousRaw: text('previous_raw').notNull(),
});

export const privateMessages = sqliteTable('private_messages', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  fromUserId: integer('from_user_id').notNull().references(() => users.id),
  toUserId: integer('to_user_id').notNull().references(() => users.id),
  subject: text('subject').notNull(),
  bodyRaw: text('body_raw').notNull(),
  bodyHtml: text('body_html').notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  isRead: integer('is_read', { mode: 'boolean' }).notNull().default(false),
  senderDeleted: integer('sender_deleted', { mode: 'boolean' }).notNull().default(false),
  recipientDeleted: integer('recipient_deleted', { mode: 'boolean' }).notNull().default(false),
}, (table) => ({
  toUserIdx: index('pm_to_user_idx').on(table.toUserId),
  fromUserIdx: index('pm_from_user_idx').on(table.fromUserId),
}));

export const auditLog = sqliteTable('audit_log', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  actorUserId: integer('actor_user_id').references(() => users.id),
  action: text('action').notNull(),
  targetType: text('target_type'),
  targetId: integer('target_id'),
  metadataJson: text('metadata_json'),
  ip: text('ip'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});

export const bans = sqliteTable('bans', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  type: text('type').notNull(), // user, ip, email
  value: text('value').notNull(),
  reason: text('reason'),
  expiresAt: integer('expires_at', { mode: 'timestamp' }),
  createdBy: integer('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});

export const emailTokens = sqliteTable('email_tokens', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  userId: integer('user_id').notNull().references(() => users.id),
  type: text('type').notNull(), // verify, reset
  tokenHash: text('token_hash').notNull(),
  expiresAt: integer('expires_at', { mode: 'timestamp' }).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});

export const settings = sqliteTable('settings', {
  key: text('key').primaryKey(),
  value: text('value').notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
