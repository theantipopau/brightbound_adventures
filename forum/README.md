# BrightBound Adventures Forum

A classic bulletin board forum built for BrightBound Adventures, designed to run on Cloudflare Pages with D1 and KV, while also supporting standard Node.js deployments.

## Features

✨ **Classic Forum Experience**
- Forum categories and subforums
- Thread creation and replies with BBCode support
- Private messaging system
- User profiles with signatures
- Search functionality
- Member list
- "Who's Online" tracking

🛡️ **Security First**
- Argon2id password hashing
- CSRF protection on all state-changing requests
- XSS prevention with output encoding
- Rate limiting (login, registration, posting, PM, search)
- Secure session management (httpOnly cookies, KV storage)
- Role-based permissions (admin, moderator, member)
- Audit logging for admin actions

👮 **Moderation Tools**
- Lock/unlock threads
- Sticky/unsticky threads
- Soft delete threads and posts
- Move threads between forums
- Ban users
- Admin panel for managing categories, forums, users, and settings

🎨 **Classic Design**
- Table-based forum layout (inspired by vBulletin v2)
- Muted color palette
- Responsive design
- BBCode support: [b], [i], [u], [url], [quote], [code]

## Tech Stack

- **Runtime**: Cloudflare Workers / Node.js
- **Framework**: Hono (lightweight router)
- **Database**: Cloudflare D1 (SQLite) / Local SQLite
- **Sessions**: Cloudflare KV / In-memory
- **Templating**: Eta
- **ORM**: Drizzle ORM
- **Language**: TypeScript

## Deployment Options

### Option 1: Cloudflare Pages (Recommended)

#### Prerequisites
- Cloudflare account
- Wrangler CLI installed: `npm install -g wrangler`
- Logged in to Wrangler: `wrangler login`

#### Setup Steps

1. **Clone and Install**
```bash
cd "f:\\BrightBound Adventures\\forum"
npm install
```

2. **Create D1 Database**
```bash
wrangler d1 create brightbound-forum-db
```

Copy the database ID from the output and update `wrangler.toml`:
```toml
[[d1_databases]]
binding = "DB"
database_name = "brightbound-forum-db"
database_id = "YOUR_D1_DATABASE_ID"  # <-- Replace this
```

3. **Create KV Namespaces**
```bash
wrangler kv:namespace create "SESSIONS"
wrangler kv:namespace create "RATELIMIT"
```

Update `wrangler.toml` with the KV IDs:
```toml
[[kv_namespaces]]
binding = "SESSIONS"
id = "YOUR_SESSIONS_KV_ID"  # <-- Replace this

[[kv_namespaces]]
binding = "RATELIMIT"
id = "YOUR_RATELIMIT_KV_ID"  # <-- Replace this
```

4. **Run Migrations**
```bash
# Apply migrations to remote D1 database
wrangler d1 migrations apply brightbound-forum-db
```

5. **Seed Database**
```bash
# Generate seed SQL
npm run db:seed

# Apply seed data to D1
wrangler d1 execute brightbound-forum-db --file=seed.sql
```

6. **Local Development**
```bash
npm run dev
```

Visit http://localhost:8788

7. **Deploy to Cloudflare Pages**
```bash
npm run deploy
```

Or connect your GitHub repository to Cloudflare Pages:
- Go to Cloudflare Dashboard → Pages
- Create a new project from Git
- Connect your repository
- Build command: `npm run build`
- Build output directory: `public`

#### Configure Custom Domain

1. Go to Cloudflare Dashboard → Pages → Your Project
2. Click "Custom domains"
3. Add `forum.brightboundadventures.com`
4. Follow DNS setup instructions

### Option 2: Node.js / Standard Deployment

#### Prerequisites
- Node.js 18+ installed
- SQLite3

#### Setup Steps

1. **Install Dependencies**
```bash
cd "f:\\BrightBound Adventures\\forum"
npm install
```

2. **Create Local Database**
```bash
# Run migrations on local SQLite database
node -e "const Database = require('better-sqlite3'); const db = new Database('./forum.db'); const fs = require('fs'); const migration = fs.readFileSync('./migrations/0001_initial_schema.sql', 'utf8'); db.exec(migration); db.close();"
```

Or manually:
```bash
sqlite3 forum.db < migrations/0001_initial_schema.sql
```

3. **Seed Database**
```bash
npm run db:seed:local
```

4. **Start Server**
```bash
npm run start:node
```

Visit http://localhost:3000

#### Docker Deployment (Optional)

Create `Dockerfile`:
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:node"]
```

Build and run:
```bash
docker build -t brightbound-forum .
docker run -p 3000:3000 -v $(pwd)/forum.db:/app/forum.db brightbound-forum
```

## Default Accounts

After seeding, you can log in with these accounts:

| Username | Password | Role |
|----------|----------|------|
| admin | AdminPass!234 | Admin |
| moderator | ModPass!234 | Moderator |
| member1 | Member1Pass!234 | Member |
| member2 | Member2Pass!234 | Member |

**⚠️ IMPORTANT**: Change these passwords immediately in production!

## Configuration

### Environment Variables

For Node.js deployments, create a `.env` file:

```env
PORT=3000
DEPLOY_TARGET=node
SESSION_SECRET=change-this-to-a-long-random-string-min-32-chars
```

For Cloudflare, update `wrangler.toml`:

```toml
[vars]
DEPLOY_TARGET = "cloudflare"
SESSION_SECRET = "change-this-in-production-min-32-chars-long"
```

### Security Settings

- Change `SESSION_SECRET` in production
- Update default admin/moderator passwords
- Configure CSP headers in production
- Set up HTTPS (automatic with Cloudflare Pages)

## Project Structure

```
forum/
├── functions/           # Cloudflare Pages Functions
│   └── [[path]].ts     # Catch-all handler
├── migrations/          # SQL migrations
│   └── 0001_initial_schema.sql
├── public/             # Static assets
│   ├── css/
│   │   └── classic.css
│   └── img/
├── scripts/            # Utility scripts
│   ├── seed.ts         # Generate seed SQL
│   └── seed-local.ts   # Seed local database
├── src/
│   ├── bbcode/         # BBCode parser
│   ├── db/             # Database schema and queries
│   ├── middleware/     # Auth and other middleware
│   ├── routes/         # Route handlers
│   ├── security/       # Security utilities
│   ├── templates/      # Eta templates
│   └── app.ts          # Main app
├── node-server.ts      # Node.js adapter
├── package.json
├── tsconfig.json
├── wrangler.toml       # Cloudflare configuration
└── README.md
```

## BBCode Support

The forum supports the following BBCode tags:

- `[b]bold[/b]` → **bold**
- `[i]italic[/i]` → *italic*
- `[u]underline[/u]` → underline
- `[url]https://example.com[/url]` → clickable link
- `[url=https://example.com]text[/url]` → named link
- `[quote]text[/quote]` → blockquote
- `[quote=author]text[/quote]` → blockquote with author
- `[code]code[/code]` → code block

## API Routes

### Public Routes
- `GET /` - Forum index
- `GET /forum/:id/:slug` - Forum view (thread list)
- `GET /thread/:id/:slug` - Thread view (posts)
- `GET /user/:id/:username` - User profile
- `GET /search` - Search
- `GET /members` - Member list

### Auth Routes
- `GET /login` - Login page
- `POST /login` - Login handler
- `GET /register` - Registration page
- `POST /register` - Registration handler
- `GET /logout` - Logout

### User Routes (require auth)
- `GET /thread/new?forumId=X` - New thread form
- `POST /thread/new` - Create thread
- `POST /thread/:id/reply` - Reply to thread
- `GET /post/:id/edit` - Edit post form
- `POST /post/:id/edit` - Update post
- `GET /messages` - Inbox
- `GET /messages/sent` - Sent messages
- `GET /messages/compose` - Compose message
- `POST /messages/compose` - Send message

### Moderator Routes
- `POST /thread/:id/tools` - Lock/unlock/sticky/delete thread
- `POST /post/:id/delete` - Soft delete post

### Admin Routes
- `GET /admin` - Admin dashboard
- `GET /admin/categories` - Manage categories
- `GET /admin/forums` - Manage forums
- `GET /admin/users` - Manage users
- `GET /admin/settings` - Forum settings

## Security Features

### Password Hashing
- Uses Argon2id with strong parameters
- Per-user salt
- Memory cost: 19 MiB
- Time cost: 2 iterations
- Parallelism: 1

### CSRF Protection
- Token generated per session
- Validated on all POST/PUT/DELETE requests
- HttpOnly cookie storage

### Rate Limiting
- Login: 5 attempts per 15 minutes
- Registration: 3 per hour
- Posts: 10 per minute
- PMs: 5 per minute
- Search: 20 per minute

### Session Security
- HttpOnly cookies
- SameSite=Lax
- 30-day expiration
- Stored in KV (Cloudflare) or memory (Node)
- Session rotation on privilege change

## Troubleshooting

### Cloudflare Pages

**Issue**: `Error: D1_ERROR`
- Ensure migrations are applied: `wrangler d1 migrations apply brightbound-forum-db`
- Check database ID in `wrangler.toml` matches your D1 database

**Issue**: `Error: KV namespace not found`
- Verify KV namespace IDs in `wrangler.toml`
- Create namespaces if missing: `wrangler kv:namespace create "SESSIONS"`

**Issue**: Template rendering errors
- Check that all template files exist in `src/templates/`
- Verify Eta syntax is correct

### Node.js

**Issue**: `Error: Cannot find module 'better-sqlite3'`
- Run `npm install` to install all dependencies

**Issue**: Database locked
- Close any other connections to `forum.db`
- Restart the Node.js server

**Issue**: Port already in use
- Change PORT in `.env` or use `PORT=3001 npm run start:node`

## Performance

### Cloudflare Pages
- Global CDN distribution
- Edge rendering (SSR at the edge)
- D1 queries cached at edge
- KV with global replication
- Automatic HTTPS

### Node.js
- Local SQLite (fast reads/writes)
- In-memory session storage
- Can scale horizontally with shared database

## License

This is a custom-built forum for BrightBound Adventures. All code is original and does not contain any proprietary code, templates, or assets from other forum software.

## Support

For issues or questions:
1. Check this README
2. Review error logs
3. Check Cloudflare Dashboard for deployment issues
4. Verify database migrations are applied

## Development

### Adding New Features

1. **Database Changes**
   - Create new migration in `migrations/`
   - Update schema in `src/db/schema.ts`
   - Run migrations

2. **New Routes**
   - Add route handler in `src/routes/`
   - Import and mount in `src/app.ts`
   - Add template in `src/templates/`

3. **Security Considerations**
   - Add CSRF token to forms
   - Apply rate limiting to sensitive endpoints
   - Check permissions server-side
   - Sanitize user input
   - Use BBCode parser for user content

### Testing

Test locally before deploying:

**Cloudflare Pages:**
```bash
npm run dev
```

**Node.js:**
```bash
npm run start:node
```

Test with different user roles:
- Admin: Full access
- Moderator: Can lock/sticky/delete
- Member: Can post and reply
- Guest: Read-only

## Maintenance

### Database Backups

**Cloudflare D1:**
```bash
wrangler d1 export brightbound-forum-db --output=backup.sql
```

**Local SQLite:**
```bash
sqlite3 forum.db .dump > backup.sql
```

### Update Forum Settings
- Login as admin
- Go to `/admin/settings`
- Update site name, description, etc.

### User Management
- Login as admin
- Go to `/admin/users`
- Change roles, ban users, etc.

---

Built with ❤️ for BrightBound Adventures
