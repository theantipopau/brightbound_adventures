import { hashPassword } from '../src/security/crypto';
import { parseBBCode } from '../src/bbcode/parser';

// This script generates SQL for seeding the database
// Run: wrangler d1 execute brightbound-forum-db --file=seed.sql

async function generateSeedSQL() {
  const now = Date.now();
  
  // Hash passwords
  const adminHash = await hashPassword('AdminPass!234');
  const modHash = await hashPassword('ModPass!234');
  const user1Hash = await hashPassword('Member1Pass!234');
  const user2Hash = await hashPassword('Member2Pass!234');
  
  const sql = `
-- Seed Data for BrightBound Adventures Forum

-- Users
INSERT INTO users (id, username, email, password_hash, role, is_verified, is_banned, created_at, last_active_at, signature) VALUES
(1, 'admin', 'admin@example.com', '${adminHash}', 'admin', 1, 0, ${now}, ${now}, 'Forum Administrator'),
(2, 'moderator', 'mod@example.com', '${modHash}', 'moderator', 1, 0, ${now}, ${now}, 'Forum Moderator - Here to help!'),
(3, 'member1', 'member1@example.com', '${user1Hash}', 'member', 1, 0, ${now}, ${now}, NULL),
(4, 'member2', 'member2@example.com', '${user2Hash}', 'member', 1, 0, ${now}, ${now}, 'Adventure enthusiast!');

-- Categories
INSERT INTO categories (id, title, sort_order) VALUES
(1, 'General Discussion', 0),
(2, 'Adventures & Trips', 10);

-- Forums
INSERT INTO forums (id, category_id, title, description, sort_order, thread_count, post_count) VALUES
(1, 1, 'Welcome & Introductions', 'New to BrightBound Adventures? Introduce yourself here!', 0, 0, 0),
(2, 1, 'General Chat', 'Discuss anything and everything related to outdoor adventures', 10, 0, 0),
(3, 2, 'Trip Reports', 'Share your adventure stories and experiences', 0, 0, 0),
(4, 2, 'Planning & Gear', 'Plan your next adventure and discuss gear recommendations', 10, 0, 0);

-- Threads
INSERT INTO threads (id, forum_id, title, slug, created_by, created_at, updated_at, is_locked, is_sticky, views, reply_count, last_post_at, last_post_by) VALUES
(1, 1, 'Welcome to BrightBound Adventures Forum!', 'welcome-to-brightbound-adventures-forum', 1, ${now}, ${now}, 0, 1, 0, 2, ${now}, 3),
(2, 2, 'Favorite hiking trails?', 'favorite-hiking-trails', 3, ${now}, ${now}, 0, 0, 0, 1, ${now}, 4),
(3, 3, 'My weekend camping trip to the mountains', 'my-weekend-camping-trip-to-the-mountains', 4, ${now}, ${now}, 0, 0, 0, 1, ${now}, 2);

-- Posts
INSERT INTO posts (id, thread_id, created_by, created_at, content_raw, content_html, is_deleted) VALUES
(1, 1, 1, ${now}, 
'[b]Welcome to the BrightBound Adventures Forum![/b]

We''re excited to have you here. This is a place for outdoor enthusiasts to share stories, plan trips, and connect with fellow adventurers.

[b]Getting Started:[/b]
• Introduce yourself in this forum
• Check out our [url=/forum/3]Trip Reports[/url] for inspiration
• Share your adventures and experiences
• Be respectful and follow our community guidelines

Happy adventuring!',
'${parseBBCode("[b]Welcome to the BrightBound Adventures Forum![/b]\n\nWe're excited to have you here. This is a place for outdoor enthusiasts to share stories, plan trips, and connect with fellow adventurers.\n\n[b]Getting Started:[/b]\n• Introduce yourself in this forum\n• Check out our [url=/forum/3]Trip Reports[/url] for inspiration\n• Share your adventures and experiences\n• Be respectful and follow our community guidelines\n\nHappy adventuring!")}',
0),

(2, 1, 3, ${now + 1000},
'Thanks for the warm welcome! I''m excited to be part of this community. I love hiking and camping, and I''m always looking for new trails to explore.',
'Thanks for the warm welcome! I''m excited to be part of this community. I love hiking and camping, and I''m always looking for new trails to explore.',
0),

(3, 1, 4, ${now + 2000},
'Hello everyone! Looking forward to sharing my adventures and learning from all of you.',
'Hello everyone! Looking forward to sharing my adventures and learning from all of you.',
0),

(4, 2, 3, ${now},
'What are your favorite hiking trails? I''m looking for recommendations for day hikes within 2-3 hours of the city.

I prefer trails with [b]good views[/b] and not too crowded. Moderate difficulty is perfect for me!',
'What are your favorite hiking trails? I''m looking for recommendations for day hikes within 2-3 hours of the city.<br><br>I prefer trails with <strong>good views</strong> and not too crowded. Moderate difficulty is perfect for me!',
0),

(5, 2, 4, ${now + 1000},
'I really enjoy the [b]Eagle Peak Trail[/b]. It''s about 2 hours away and has amazing views from the summit. The trail is well-maintained and usually not too busy on weekdays.

Total distance is about 8 miles round trip with 1,500 ft elevation gain.',
'I really enjoy the <strong>Eagle Peak Trail</strong>. It''s about 2 hours away and has amazing views from the summit. The trail is well-maintained and usually not too busy on weekdays.<br><br>Total distance is about 8 miles round trip with 1,500 ft elevation gain.',
0),

(6, 3, 4, ${now},
'Just got back from an amazing [b]weekend camping trip[/b] in the mountains! 

[b]Highlights:[/b]
• Perfect weather - clear skies both nights
• Saw a beautiful sunrise from our campsite
• Spotted deer and various birds
• Campfire stories under the stars

The trail was well-marked and the campsite had great facilities. Highly recommend this location for anyone looking for a peaceful mountain getaway!',
'Just got back from an amazing <strong>weekend camping trip</strong> in the mountains!<br><br><strong>Highlights:</strong><br>• Perfect weather - clear skies both nights<br>• Saw a beautiful sunrise from our campsite<br>• Spotted deer and various birds<br>• Campfire stories under the stars<br><br>The trail was well-marked and the campsite had great facilities. Highly recommend this location for anyone looking for a peaceful mountain getaway!',
0),

(7, 3, 2, ${now + 1000},
'Sounds amazing! Thanks for sharing. I''ve been wanting to try camping in that area. Did you need any special permits?',
'Sounds amazing! Thanks for sharing. I''ve been wanting to try camping in that area. Did you need any special permits?',
0);

-- Update forum stats
UPDATE forums SET thread_count = 1, post_count = 3, last_post_at = ${now + 2000}, last_post_user_id = 4 WHERE id = 1;
UPDATE forums SET thread_count = 1, post_count = 2, last_post_at = ${now + 1000}, last_post_user_id = 4 WHERE id = 2;
UPDATE forums SET thread_count = 1, post_count = 2, last_post_at = ${now + 1000}, last_post_user_id = 2 WHERE id = 3;

-- Update thread stats
UPDATE threads SET reply_count = 2, last_post_at = ${now + 2000}, last_post_by = 4 WHERE id = 1;
UPDATE threads SET reply_count = 1, last_post_at = ${now + 1000}, last_post_by = 4 WHERE id = 2;
UPDATE threads SET reply_count = 1, last_post_at = ${now + 1000}, last_post_by = 2 WHERE id = 3;

-- Settings
INSERT INTO settings (key, value, updated_at) VALUES
('site_name', 'BrightBound Adventures Forum', ${now}),
('site_description', 'A community for outdoor enthusiasts', ${now}),
('allow_registration', 'true', ${now});
`;
  
  console.log(sql);
}

generateSeedSQL().catch(console.error);
