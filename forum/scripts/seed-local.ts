import Database from 'better-sqlite3';
import { hashPassword } from '../src/security/crypto';
import { parseBBCode } from '../src/bbcode/parser';

async function seed() {
  const db = new Database('./forum.db');
  
  console.log('Seeding local database...');
  
  const now = Date.now();
  
  // Hash passwords
  const adminHash = await hashPassword('AdminPass!234');
  const modHash = await hashPassword('ModPass!234');
  const user1Hash = await hashPassword('Member1Pass!234');
  const user2Hash = await hashPassword('Member2Pass!234');
  
  // Users
  db.prepare(`INSERT INTO users (id, username, email, password_hash, role, is_verified, is_banned, created_at, last_active_at, signature) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    1, 'admin', 'admin@example.com', adminHash, 'admin', 1, 0, now, now, 'Forum Administrator'
  );
  
  db.prepare(`INSERT INTO users (id, username, email, password_hash, role, is_verified, is_banned, created_at, last_active_at, signature) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    2, 'moderator', 'mod@example.com', modHash, 'moderator', 1, 0, now, now, 'Forum Moderator - Here to help!'
  );
  
  db.prepare(`INSERT INTO users (id, username, email, password_hash, role, is_verified, is_banned, created_at, last_active_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    3, 'member1', 'member1@example.com', user1Hash, 'member', 1, 0, now, now
  );
  
  db.prepare(`INSERT INTO users (id, username, email, password_hash, role, is_verified, is_banned, created_at, last_active_at, signature) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    4, 'member2', 'member2@example.com', user2Hash, 'member', 1, 0, now, now, 'Adventure enthusiast!'
  );
  
  // Categories
  db.prepare(`INSERT INTO categories (id, title, sort_order) VALUES (?, ?, ?)`).run(1, 'General Discussion', 0);
  db.prepare(`INSERT INTO categories (id, title, sort_order) VALUES (?, ?, ?)`).run(2, 'Adventures & Trips', 10);
  
  // Forums
  db.prepare(`INSERT INTO forums (id, category_id, title, description, sort_order) VALUES (?, ?, ?, ?, ?)`).run(
    1, 1, 'Welcome & Introductions', 'New to BrightBound Adventures? Introduce yourself here!', 0
  );
  db.prepare(`INSERT INTO forums (id, category_id, title, description, sort_order) VALUES (?, ?, ?, ?, ?)`).run(
    2, 1, 'General Chat', 'Discuss anything and everything related to outdoor adventures', 10
  );
  db.prepare(`INSERT INTO forums (id, category_id, title, description, sort_order) VALUES (?, ?, ?, ?, ?)`).run(
    3, 2, 'Trip Reports', 'Share your adventure stories and experiences', 0
  );
  db.prepare(`INSERT INTO forums (id, category_id, title, description, sort_order) VALUES (?, ?, ?, ?, ?)`).run(
    4, 2, 'Planning & Gear', 'Plan your next adventure and discuss gear recommendations', 10
  );
  
  // Threads
  db.prepare(`INSERT INTO threads (id, forum_id, title, slug, created_by, created_at, updated_at, is_locked, is_sticky, views, reply_count, last_post_at, last_post_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    1, 1, 'Welcome to BrightBound Adventures Forum!', 'welcome-to-brightbound-adventures-forum', 1, now, now, 0, 1, 0, 2, now + 2000, 4
  );
  db.prepare(`INSERT INTO threads (id, forum_id, title, slug, created_by, created_at, updated_at, is_locked, is_sticky, views, reply_count, last_post_at, last_post_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    2, 2, 'Favorite hiking trails?', 'favorite-hiking-trails', 3, now, now, 0, 0, 0, 1, now + 1000, 4
  );
  db.prepare(`INSERT INTO threads (id, forum_id, title, slug, created_by, created_at, updated_at, is_locked, is_sticky, views, reply_count, last_post_at, last_post_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`).run(
    3, 3, 'My weekend camping trip to the mountains', 'my-weekend-camping-trip-to-the-mountains', 4, now, now, 0, 0, 0, 1, now + 1000, 2
  );
  
  // Posts
  const posts = [
    {
      id: 1, threadId: 1, createdBy: 1, createdAt: now,
      raw: '[b]Welcome to the BrightBound Adventures Forum![/b]\n\nWe\'re excited to have you here. This is a place for outdoor enthusiasts to share stories, plan trips, and connect with fellow adventurers.\n\n[b]Getting Started:[/b]\n• Introduce yourself in this forum\n• Check out our Trip Reports for inspiration\n• Share your adventures and experiences\n• Be respectful and follow our community guidelines\n\nHappy adventuring!'
    },
    {
      id: 2, threadId: 1, createdBy: 3, createdAt: now + 1000,
      raw: 'Thanks for the warm welcome! I\'m excited to be part of this community. I love hiking and camping, and I\'m always looking for new trails to explore.'
    },
    {
      id: 3, threadId: 1, createdBy: 4, createdAt: now + 2000,
      raw: 'Hello everyone! Looking forward to sharing my adventures and learning from all of you.'
    },
    {
      id: 4, threadId: 2, createdBy: 3, createdAt: now,
      raw: 'What are your favorite hiking trails? I\'m looking for recommendations for day hikes within 2-3 hours of the city.\n\nI prefer trails with [b]good views[/b] and not too crowded. Moderate difficulty is perfect for me!'
    },
    {
      id: 5, threadId: 2, createdBy: 4, createdAt: now + 1000,
      raw: 'I really enjoy the [b]Eagle Peak Trail[/b]. It\'s about 2 hours away and has amazing views from the summit. The trail is well-maintained and usually not too busy on weekdays.\n\nTotal distance is about 8 miles round trip with 1,500 ft elevation gain.'
    },
    {
      id: 6, threadId: 3, createdBy: 4, createdAt: now,
      raw: 'Just got back from an amazing [b]weekend camping trip[/b] in the mountains!\n\n[b]Highlights:[/b]\n• Perfect weather - clear skies both nights\n• Saw a beautiful sunrise from our campsite\n• Spotted deer and various birds\n• Campfire stories under the stars\n\nThe trail was well-marked and the campsite had great facilities. Highly recommend this location for anyone looking for a peaceful mountain getaway!'
    },
    {
      id: 7, threadId: 3, createdBy: 2, createdAt: now + 1000,
      raw: 'Sounds amazing! Thanks for sharing. I\'ve been wanting to try camping in that area. Did you need any special permits?'
    }
  ];
  
  for (const post of posts) {
    const html = parseBBCode(post.raw);
    db.prepare(`INSERT INTO posts (id, thread_id, created_by, created_at, content_raw, content_html, is_deleted) VALUES (?, ?, ?, ?, ?, ?, ?)`).run(
      post.id, post.threadId, post.createdBy, post.createdAt, post.raw, html, 0
    );
  }
  
  // Update forum stats
  db.prepare(`UPDATE forums SET thread_count = ?, post_count = ?, last_post_at = ?, last_post_user_id = ? WHERE id = ?`).run(1, 3, now + 2000, 4, 1);
  db.prepare(`UPDATE forums SET thread_count = ?, post_count = ?, last_post_at = ?, last_post_user_id = ? WHERE id = ?`).run(1, 2, now + 1000, 4, 2);
  db.prepare(`UPDATE forums SET thread_count = ?, post_count = ?, last_post_at = ?, last_post_user_id = ? WHERE id = ?`).run(1, 2, now + 1000, 2, 3);
  
  // Settings
  db.prepare(`INSERT INTO settings (key, value, updated_at) VALUES (?, ?, ?)`).run('site_name', 'BrightBound Adventures Forum', now);
  db.prepare(`INSERT INTO settings (key, value, updated_at) VALUES (?, ?, ?)`).run('site_description', 'A community for outdoor enthusiasts', now);
  db.prepare(`INSERT INTO settings (key, value, updated_at) VALUES (?, ?, ?)`).run('allow_registration', 'true', now);
  
  db.close();
  
  console.log('✅ Database seeded successfully!');
  console.log('\nTest accounts:');
  console.log('  Admin: admin / AdminPass!234');
  console.log('  Moderator: moderator / ModPass!234');
  console.log('  Member: member1 / Member1Pass!234');
  console.log('  Member: member2 / Member2Pass!234');
}

seed().catch(console.error);
