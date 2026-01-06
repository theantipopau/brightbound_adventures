# Quick Start Guide - BrightBound Adventures Forum

## 🚀 5-Minute Local Setup (Node.js)

Perfect for testing locally before deploying to Cloudflare.

### Step 1: Install Dependencies
```powershell
cd "f:\BrightBound Adventures\forum"
npm install
```

### Step 2: Create and Seed Database
```powershell
# Create the database
sqlite3 forum.db < migrations/0001_initial_schema.sql

# Or if sqlite3 is not in PATH:
npm run db:migrate:local

# Seed with test data
npm run db:seed:local
```

### Step 3: Start Server
```powershell
npm run start:node
```

### Step 4: Open Browser
Visit: http://localhost:3000

### Step 5: Login
- **Admin**: admin / AdminPass!234
- **Moderator**: moderator / ModPass!234

---

## ☁️ Cloudflare Pages Deployment

### Prerequisites
```powershell
npm install -g wrangler
wrangler login
```

### Step 1: Create D1 Database
```powershell
wrangler d1 create brightbound-forum-db
```

**Copy the database_id** from output and update `wrangler.toml`:
```toml
database_id = "paste-your-database-id-here"
```

### Step 2: Create KV Namespaces
```powershell
wrangler kv:namespace create "SESSIONS"
wrangler kv:namespace create "RATELIMIT"
```

**Copy the ids** and update `wrangler.toml`:
```toml
[[kv_namespaces]]
binding = "SESSIONS"
id = "paste-sessions-id-here"

[[kv_namespaces]]
binding = "RATELIMIT"
id = "paste-ratelimit-id-here"
```

### Step 3: Apply Migrations
```powershell
wrangler d1 migrations apply brightbound-forum-db
```

### Step 4: Seed Database
```powershell
# Generate seed SQL
tsx scripts/seed.ts > seed.sql

# Apply to D1
wrangler d1 execute brightbound-forum-db --file=seed.sql
```

### Step 5: Test Locally
```powershell
npm run dev
```

Visit: http://localhost:8788

### Step 6: Deploy
```powershell
npm run deploy
```

Your forum will be live at: `https://[project-name].pages.dev`

### Step 7: Custom Domain (Optional)
1. Go to Cloudflare Dashboard → Pages → Your Project
2. Click "Custom domains"
3. Add: `forum.brightboundadventures.com`
4. Follow DNS instructions

---

## 🔐 Post-Deployment Security Checklist

### Immediate Actions:
1. **Change Admin Password**
   - Login as admin
   - Go to profile settings
   - Change password

2. **Change SESSION_SECRET**
   - Update in `wrangler.toml` (Cloudflare)
   - Or `.env` (Node.js)
   - Use a strong random string (32+ characters)

3. **Change Default Passwords**
   - Login to each default account
   - Update passwords through profile

### Recommended:
4. **Delete Test Accounts** (if not needed)
   - Go to Admin Panel → Users
   - Delete member1, member2

5. **Review Forum Settings**
   - Admin Panel → Settings
   - Update site name, description
   - Configure registration settings

6. **Test Security Features**
   - Try registering a new account
   - Test rate limiting (try multiple logins)
   - Test CSRF protection
   - Test BBCode parsing

---

## 📝 Common Commands

### Local Development (Node.js)
```powershell
npm run start:node          # Start Node.js server
npm run db:seed:local       # Seed local database
```

### Cloudflare Development
```powershell
npm run dev                 # Start local Cloudflare Pages dev server
npm run deploy              # Deploy to Cloudflare Pages
npm run db:migrate          # Apply migrations to D1
```

### Database Management
```powershell
# Local SQLite
sqlite3 forum.db ".dump" > backup.sql    # Backup
sqlite3 forum.db < backup.sql            # Restore

# Cloudflare D1
wrangler d1 export brightbound-forum-db --output=backup.sql  # Backup
wrangler d1 execute brightbound-forum-db --file=backup.sql   # Restore
```

---

## 🐛 Troubleshooting

### "Template not found" Error
**Node.js**: Make sure you're in the correct directory when starting the server.
```powershell
cd "f:\BrightBound Adventures\forum"
npm run start:node
```

### "Database locked" Error
**Node.js**: Close any other connections to the database.
```powershell
# Stop all node processes
taskkill /F /IM node.exe
# Restart server
npm run start:node
```

### "KV namespace not found"
**Cloudflare**: Verify KV namespace IDs in `wrangler.toml` are correct.
```powershell
wrangler kv:namespace list
```

### Port Already in Use
**Node.js**: Change the port.
```powershell
$env:PORT=3001; npm run start:node
```

### Migrations Not Applied
```powershell
# Cloudflare
wrangler d1 migrations list brightbound-forum-db
wrangler d1 migrations apply brightbound-forum-db

# Local
npm run db:migrate:local
```

---

## 📖 Next Steps

1. **Customize Appearance**
   - Edit `public/css/classic.css`
   - Update logo and branding
   - Customize colors

2. **Add Forums and Categories**
   - Login as admin
   - Go to Admin Panel
   - Add your own forums

3. **Configure Settings**
   - Admin Panel → Settings
   - Set site name, description
   - Configure user permissions

4. **Invite Users**
   - Share registration link
   - Or create accounts manually in Admin Panel

5. **Monitor Activity**
   - Check "Who's Online"
   - Review audit log in Admin Panel
   - Monitor for spam/abuse

---

## 🎯 Production Checklist

Before going live with real users:

- [ ] Change all default passwords
- [ ] Update SESSION_SECRET
- [ ] Configure custom domain
- [ ] Set up HTTPS (automatic with Cloudflare)
- [ ] Test all security features
- [ ] Create backup procedure
- [ ] Delete test/demo content
- [ ] Create your actual forum structure
- [ ] Test registration flow
- [ ] Test posting, replying, PMing
- [ ] Test moderation tools
- [ ] Review and customize CSS
- [ ] Add forum rules/guidelines
- [ ] Test on mobile devices

---

## 💡 Tips

### Performance
- Cloudflare Pages serves from global CDN
- D1 is replicated to multiple locations
- Static assets are cached at edge
- SSR happens at the edge (fast!)

### Scaling
- Cloudflare: Automatically scales with traffic
- Node.js: Can run multiple instances behind load balancer

### Backups
- Schedule regular D1 exports
- Store backups securely
- Test restore procedure

### Monitoring
- Check Cloudflare Analytics
- Monitor error rates
- Watch for abuse patterns
- Review audit logs regularly

---

## 📞 Support

### Resources
- README.md - Full documentation
- migrations/ - Database schema
- src/ - Source code with comments

### Common Issues
- Check README.md Troubleshooting section
- Verify all migrations are applied
- Check Cloudflare Dashboard for errors
- Review browser console for client errors

---

**Ready to go live?** 🎉

Your forum is now set up and ready for your community!
