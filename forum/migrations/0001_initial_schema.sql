-- Migration: 0001_initial_schema.sql
-- Create all tables for the forum

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'member',
  is_verified INTEGER NOT NULL DEFAULT 0,
  is_banned INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  last_active_at INTEGER,
  signature TEXT,
  settings_json TEXT
);

CREATE INDEX IF NOT EXISTS username_idx ON users(username);
CREATE INDEX IF NOT EXISTS email_idx ON users(email);

CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS forums (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  last_post_at INTEGER,
  last_post_user_id INTEGER,
  thread_count INTEGER NOT NULL DEFAULT 0,
  post_count INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE INDEX IF NOT EXISTS forum_category_idx ON forums(category_id);

CREATE TABLE IF NOT EXISTS threads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  forum_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  slug TEXT NOT NULL,
  created_by INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_locked INTEGER NOT NULL DEFAULT 0,
  is_sticky INTEGER NOT NULL DEFAULT 0,
  views INTEGER NOT NULL DEFAULT 0,
  reply_count INTEGER NOT NULL DEFAULT 0,
  last_post_at INTEGER NOT NULL,
  last_post_by INTEGER,
  FOREIGN KEY (forum_id) REFERENCES forums(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (last_post_by) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS thread_forum_idx ON threads(forum_id);
CREATE INDEX IF NOT EXISTS thread_last_post_idx ON threads(last_post_at);

CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  thread_id INTEGER NOT NULL,
  created_by INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER,
  content_raw TEXT NOT NULL,
  content_html TEXT NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  deleted_by INTEGER,
  deleted_at INTEGER,
  FOREIGN KEY (thread_id) REFERENCES threads(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (deleted_by) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS post_thread_idx ON posts(thread_id);
CREATE INDEX IF NOT EXISTS post_created_idx ON posts(created_at);

CREATE TABLE IF NOT EXISTS post_edits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER NOT NULL,
  edited_by INTEGER NOT NULL,
  edited_at INTEGER NOT NULL,
  previous_raw TEXT NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (edited_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS private_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  from_user_id INTEGER NOT NULL,
  to_user_id INTEGER NOT NULL,
  subject TEXT NOT NULL,
  body_raw TEXT NOT NULL,
  body_html TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  is_read INTEGER NOT NULL DEFAULT 0,
  sender_deleted INTEGER NOT NULL DEFAULT 0,
  recipient_deleted INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (from_user_id) REFERENCES users(id),
  FOREIGN KEY (to_user_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS pm_to_user_idx ON private_messages(to_user_id);
CREATE INDEX IF NOT EXISTS pm_from_user_idx ON private_messages(from_user_id);

CREATE TABLE IF NOT EXISTS audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  actor_user_id INTEGER,
  action TEXT NOT NULL,
  target_type TEXT,
  target_id INTEGER,
  metadata_json TEXT,
  ip TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (actor_user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS bans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  value TEXT NOT NULL,
  reason TEXT,
  expires_at INTEGER,
  created_by INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS email_tokens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  type TEXT NOT NULL,
  token_hash TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
