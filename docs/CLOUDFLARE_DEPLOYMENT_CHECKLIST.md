# Cloudflare Deployment Checklist
## Ready to Deploy Phase 1 Backend

**Status**: ✅ All Flutter code compiled and verified  
**Date**: January 12, 2026  
**Estimated Deployment Time**: 1-2 hours

---

## Prerequisites

### What You Need
- [ ] Free Cloudflare account (https://dash.cloudflare.com)
- [ ] Node.js 16+ installed on your computer
- [ ] Terminal/PowerShell access
- [ ] 1-2 hours of focused time

### Verify Setup
```powershell
node --version     # Should show v16.0.0 or higher
npm --version      # Should show 7.0.0 or higher
```

---

## Step-by-Step Deployment

### Phase 1: Cloudflare Account & Project Setup (15 minutes)

#### 1.1 Create Cloudflare Account
- [ ] Go to https://dash.cloudflare.com
- [ ] Sign up (email + password)
- [ ] Verify email
- [ ] You now have free Workers + D1 access

#### 1.2 Note Your Account ID
- [ ] Login to Cloudflare dashboard
- [ ] Go to **Workers & Pages**
- [ ] Copy your **Account ID** from the right sidebar
- [ ] Save it - you'll need it in 10 minutes

#### 1.3 Create API Token
- [ ] Go to **My Profile** (bottom left)
- [ ] Click **API Tokens**
- [ ] Click **Create Token** → Use template **"Edit Cloudflare Workers"**
- [ ] Permissions auto-set to correct values
- [ ] Click **Create Token**
- [ ] **Copy the token immediately** and save it somewhere safe

### Phase 2: Local Setup (10 minutes)

#### 2.1 Install Wrangler CLI
```powershell
npm install -g wrangler
wrangler --version  # Should show version 3.x
```

#### 2.2 Login to Cloudflare
```powershell
wrangler login
# Opens browser, click "Allow" to authorize
# Creates ~/.wrangler/config.toml with your credentials
```

#### 2.3 Create Project Directory
```powershell
mkdir brightbound-api
cd brightbound-api
wrangler init
```

**When prompted**:
- `What type of application?` → Choose **"fetch handler"**
- `Do you want to use git?` → **"no"** (already have main repo)
- `Do you want to install dependencies?` → **"no"** (we'll do manual setup)

This creates:
```
brightbound-api/
├── src/index.ts
├── wrangler.toml
├── package.json
├── tsconfig.json
└── .gitignore
```

### Phase 3: Configure Wrangler (10 minutes)

#### 3.1 Create wrangler.toml

Open `brightbound-api/wrangler.toml` and replace entire contents with:

```toml
name = "brightbound-api"
main = "src/index.ts"
compatibility_date = "2024-01-12"
workers_dev = true

[env.production]
vars = { ENVIRONMENT = "production" }

[[d1_databases]]
binding = "DB"
database_name = "brightbound"
```

**Note**: We'll add the `database_id` after creating the D1 database (next phase)

#### 3.2 Install Dependencies
```powershell
npm install
npm install itty-router itty-router-extras
```

### Phase 4: Create D1 Database (10 minutes)

#### 4.1 Create Database
```powershell
wrangler d1 create brightbound
```

**Output will show**:
```
✓ Creating D1 database brightbound
Created DB!

Binding = DB
Database ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

#### 4.2 Copy Database ID
- [ ] Copy the **Database ID** from output
- [ ] Update `wrangler.toml`:

```toml
[[d1_databases]]
binding = "DB"
database_name = "brightbound"
database_id = "YOUR_DATABASE_ID_HERE"  # <- Paste here
```

#### 4.3 Verify Database Created
```powershell
wrangler d1 info brightbound
```

Should show the database info.

### Phase 5: Create Database Schema (10 minutes)

#### 5.1 Create schema.sql

In `brightbound-api/` folder, create file `schema.sql`:

```sql
-- Teachers table
CREATE TABLE IF NOT EXISTS teachers (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  phone_number TEXT,
  school_district TEXT,
  grade_specialty TEXT,
  license_type TEXT DEFAULT 'free',
  max_students INTEGER DEFAULT 5,
  is_active BOOLEAN DEFAULT true,
  created_at TEXT NOT NULL,
  license_expires_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Classes table
CREATE TABLE IF NOT EXISTS classes (
  id TEXT PRIMARY KEY,
  teacher_id TEXT NOT NULL,
  name TEXT NOT NULL,
  grade_level INTEGER NOT NULL,
  description TEXT,
  is_archived BOOLEAN DEFAULT false,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

-- Class enrollments
CREATE TABLE IF NOT EXISTS class_enrollments (
  id TEXT PRIMARY KEY,
  class_id TEXT NOT NULL,
  student_id TEXT NOT NULL,
  enrolled_at TEXT NOT NULL,
  FOREIGN KEY (class_id) REFERENCES classes(id),
  UNIQUE(class_id, student_id)
);

-- Student progress tracking
CREATE TABLE IF NOT EXISTS student_progress (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL,
  teacher_id TEXT,
  class_id TEXT,
  total_questions_answered INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  last_active_date TEXT,
  updated_at TEXT NOT NULL
);

-- Auth tokens (sessions)
CREATE TABLE IF NOT EXISTS auth_tokens (
  id TEXT PRIMARY KEY,
  teacher_id TEXT NOT NULL,
  token TEXT NOT NULL UNIQUE,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);
CREATE INDEX IF NOT EXISTS idx_classes_teacher_id ON classes(teacher_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_class ON class_enrollments(class_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON class_enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_progress_student ON student_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_tokens_teacher ON auth_tokens(teacher_id);
```

#### 5.2 Apply Schema
```powershell
wrangler d1 execute brightbound --file=schema.sql
```

**Success output**:
```
Executed SQL
✓ 6 executed
```

#### 5.3 Verify Tables
```powershell
wrangler d1 execute brightbound --command="SELECT name FROM sqlite_master WHERE type='table';"
```

Should show: `teachers`, `classes`, `class_enrollments`, `student_progress`, `auth_tokens`

### Phase 6: Write Worker Code (20 minutes)

#### 6.1 Replace src/index.ts

Open `brightbound-api/src/index.ts` and replace with **complete code from [CLOUDFLARE_WORKERS_SETUP.md](CLOUDFLARE_WORKERS_SETUP.md#step-6-write-cloudflare-worker-code)** sections:
- Imports
- Types/Interfaces
- Middleware (CORS)
- Auth helpers
- All endpoints (register, login, get teacher, get classes, create class)

**File should be ~450 lines of TypeScript**

#### 6.2 Save & Verify Syntax
```powershell
npm run build
```

Should complete without errors.

### Phase 7: Deploy to Cloudflare (10 minutes)

#### 7.1 Test Locally (Optional)
```powershell
wrangler dev
# Starts local server on http://localhost:8787
# In new terminal, test:
curl http://localhost:8787/api/teachers/register
# Should return CORS headers + error response
# Press Ctrl+C to stop
```

#### 7.2 Deploy to Production
```powershell
wrangler publish
```

**Success output**:
```
✓ Uploaded brightbound-api/src/index.ts
✓ Uploaded brightbound-api/src/index.ts
✓ Success! Your worker is deployed
  https://brightbound-api.YOUR_SUBDOMAIN.workers.dev
```

#### 7.3 Save Your API URL
- [ ] Copy the deployed URL from output
- [ ] Save it - you'll use it in Flutter app
- [ ] Format: `https://brightbound-api.YOUR_SUBDOMAIN.workers.dev`

### Phase 8: Test Deployment (10 minutes)

#### 8.1 Test Registration Endpoint
```powershell
$body = @{
    email = "teacher@example.com"
    password = "TestPassword123"
    fullName = "Ms. Smith"
    schoolName = "Lincoln Elementary"
} | ConvertTo-Json

curl -X POST https://brightbound-api.YOUR_SUBDOMAIN.workers.dev/api/teachers/register `
  -H "Content-Type: application/json" `
  -Body $body
```

**Expected response** (HTTP 201):
```json
{
  "teacher": {
    "id": "uuid...",
    "email": "teacher@example.com",
    "fullName": "Ms. Smith",
    "schoolName": "Lincoln Elementary",
    "licenseType": "free",
    "maxStudents": 5,
    "createdAt": "2024-01-12T...",
    "licenseExpiresAt": "2025-01-12T..."
  },
  "token": "random-token-string"
}
```

#### 8.2 Test Login Endpoint
```powershell
$body = @{
    email = "teacher@example.com"
    password = "TestPassword123"
} | ConvertTo-Json

curl -X POST https://brightbound-api.YOUR_SUBDOMAIN.workers.dev/api/teachers/login `
  -H "Content-Type: application/json" `
  -Body $body
```

**Expected response** (HTTP 200):
```json
{
  "teacher": { ... },
  "token": "new-token-string"
}
```

#### 8.3 Verify Database
```powershell
wrangler d1 execute brightbound --command="SELECT COUNT(*) as count FROM teachers;"
```

Should show `count: 1` (your test teacher)

---

## Integration with Flutter App

Once deployed, update your Flutter app:

### 1. Update teacher_auth_service.dart

At initialization:
```dart
final authService = TeacherAuthService(
  apiBase: 'https://brightbound-api.YOUR_SUBDOMAIN.workers.dev',  // Your deployed URL
);
```

### 2. Example: Register Teacher

```dart
try {
  final account = await authService.registerTeacher(
    email: 'teacher@example.com',
    password: 'password123',
    fullName: 'Ms. Smith',
    schoolName: 'Lincoln Elementary',
  );
  
  if (account != null) {
    print('Teacher registered: ${account.email}');
    print('Token: ${authService._authToken}');
  }
} catch (e) {
  print('Error: $e');
}
```

### 3. Example: Login Teacher

```dart
try {
  final account = await authService.loginTeacher(
    email: 'teacher@example.com',
    password: 'password123',
  );
  
  if (account != null) {
    print('Logged in: ${account.fullName}');
    // Now can use ClassManagementService
  }
} catch (e) {
  print('Login failed: $e');
}
```

### 4. Initialize Class Service (after login)

```dart
final classService = ClassManagementService(
  apiBase: 'https://brightbound-api.YOUR_SUBDOMAIN.workers.dev',
  authToken: authService._authToken ?? '',
);

// Create a class
final newClass = await classService.createClass(
  teacherId: account.id,
  name: 'Grade 4A - 2024',
  gradeLevel: 4,
);
```

---

## Monitoring & Maintenance

### View Logs
```powershell
# Last 100 requests
wrangler tail

# Real-time stream (Ctrl+C to stop)
wrangler tail --format pretty
```

### Check Database
```powershell
# Count teachers
wrangler d1 execute brightbound --command="SELECT COUNT(*) FROM teachers;"

# View all teachers
wrangler d1 execute brightbound --command="SELECT id, email, full_name FROM teachers;"

# Delete test teacher
wrangler d1 execute brightbound --command="DELETE FROM teachers WHERE email = 'teacher@example.com';"
```

### Update Worker Code
```powershell
# Edit src/index.ts
# Then:
wrangler publish
```

---

## Troubleshooting

### Issue: "Database not found"
**Solution**: Verify `database_id` in `wrangler.toml` matches actual database ID
```powershell
wrangler d1 list
```

### Issue: "Token invalid"
**Solution**: Re-authenticate with Cloudflare
```powershell
wrangler logout
wrangler login
```

### Issue: "CORS error" from Flutter app
**Solution**: Endpoints already include CORS headers, but verify:
```powershell
curl -i -X OPTIONS https://your-api.workers.dev/api/teachers/register
```

Should show `Access-Control-Allow-*` headers

### Issue: "Email already registered"
**Solution**: Database persists between deployments
```powershell
wrangler d1 execute brightbound --command="DELETE FROM teachers WHERE email = 'your-email';"
```

---

## Cost Breakdown

| Item | Free Tier | Cost After |
|------|-----------|-----------|
| **Requests** | 100,000/day | $0.15 per 10K requests |
| **D1 Database** | Free | Free (no per-row charges) |
| **Storage** | 1GB | $0.50/GB/month |
| **Custom Domain** | Not needed | $0/month (use workers.dev) |

**At scale (10K teachers)**:
- 100 requests/teacher/month = 1M requests = **$15/month**
- Database storage = ~500MB = **Free** (under 1GB)
- **Total: $15-20/month**

---

## Next Steps After Deployment

1. **✅ Backend deployed** → Cloudflare Workers API live
2. **→ Build Phase 2** → Teacher dashboard UI
3. **→ Connect Flutter** → Update api URLs in services
4. **→ Test end-to-end** → Teacher registration → create class
5. **→ Launch MVP** → First teachers onboard

---

## Checklist for Success

```
Phase 1: Setup
  [ ] Cloudflare account created
  [ ] Node.js installed & verified
  [ ] API token saved securely
  
Phase 2: Project Creation
  [ ] brightbound-api folder created
  [ ] wrangler init completed
  [ ] Dependencies installed (npm install + itty-router)
  
Phase 3: Database
  [ ] D1 database created
  [ ] Database ID copied to wrangler.toml
  [ ] schema.sql created & applied
  [ ] Tables verified (6 tables exist)
  
Phase 4: Worker Code
  [ ] src/index.ts written (450+ lines)
  [ ] npm run build succeeds
  [ ] All endpoints implemented
  
Phase 5: Deployment
  [ ] wrangler publish succeeds
  [ ] API URL saved
  [ ] Registration test succeeds
  [ ] Login test succeeds
  [ ] Database records created
  
Phase 6: Integration
  [ ] Flutter app updated with API URL
  [ ] TeacherAuthService initialized
  [ ] ClassManagementService ready
  [ ] Ready for Phase 2 UI development
```

---

## Support

If you hit issues:
1. Check Cloudflare dashboard (https://dash.cloudflare.com → Workers)
2. View logs: `wrangler tail`
3. Verify database: `wrangler d1 list`
4. Check syntax: `npm run build`

All endpoints documented in [CLOUDFLARE_WORKERS_SETUP.md](CLOUDFLARE_WORKERS_SETUP.md)

---

## Ready to Deploy?

**You have everything you need:**
- ✅ Flutter code (compiled, zero errors)
- ✅ Database schema
- ✅ Worker TypeScript code
- ✅ This checklist

**Estimated time: 1.5 hours**

**Start here**: Go to https://dash.cloudflare.com and create account → Follow Phase 1 above
