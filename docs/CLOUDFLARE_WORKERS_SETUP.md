# Cloudflare Workers + D1 Backend Setup
## Free Alternative to Firebase

**Why Cloudflare?**
- ✅ 100,000 free requests/day (plenty for teachers)
- ✅ Automatic SSL, DDoS protection, caching
- ✅ D1 SQLite database (free tier)
- ✅ Pay-as-you-go after free tier ($0.15/10k requests)
- ✅ No vendor lock-in (can migrate anytime)

---

## Architecture

```
Flutter App (Offline-first with Hive)
         ↓
    HTTP Requests
         ↓
Cloudflare Workers (API Gateway)
         ↓
    D1 SQLite Database
```

**Data Flow**:
1. App makes REST calls to `https://api.brightbound.workers.dev/api/*`
2. Cloudflare Workers validates auth & routes to database
3. Responses returned as JSON
4. App syncs when online, queues when offline

---

## Step 1: Install Wrangler (Cloudflare CLI)

```bash
npm install -g wrangler
wrangler login
```

This creates a `.wrangler` folder with your Cloudflare account credentials.

---

## Step 2: Create Cloudflare Project

```bash
cd your-project-directory
wrangler init brightbound-api
cd brightbound-api
```

This creates:
```
brightbound-api/
├── src/
│   └── index.ts           # Main worker code
├── wrangler.toml          # Configuration
├── package.json
└── tsconfig.json
```

---

## Step 3: Configure wrangler.toml

```toml
name = "brightbound-api"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[env.production]
route = "api.brightbound.adventures/*"
zone_id = "YOUR_CLOUDFLARE_ZONE_ID"

[[d1_databases]]
binding = "DB"
database_name = "brightbound"
database_id = "YOUR_DATABASE_ID"

[env.development]
vars = { ENVIRONMENT = "development" }

[env.production]
vars = { ENVIRONMENT = "production" }
```

---

## Step 4: Create D1 Database

```bash
# Create the database
wrangler d1 create brightbound

# Output will show your database_id - add to wrangler.toml
```

---

## Step 5: Create Database Schema

Create `schema.sql`:

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

-- Class enrollment
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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);
CREATE INDEX IF NOT EXISTS idx_classes_teacher_id ON classes(teacher_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_class ON class_enrollments(class_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON class_enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_progress_student ON student_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_tokens_teacher ON auth_tokens(teacher_id);
```

Apply schema:

```bash
wrangler d1 execute brightbound --file=schema.sql
```

---

## Step 6: Write Cloudflare Worker Code

Create `src/index.ts`:

```typescript
import { Router } from 'itty-router';
import { json, status } from 'itty-router-extras';
import crypto from 'crypto';

const router = Router();

interface Env {
  DB: D1Database;
  ENVIRONMENT: string;
}

// Middleware: CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

router.options('*', () => new Response(null, { headers: corsHeaders }));

// Auth token validation
async function validateToken(
  token: string,
  env: Env
): Promise<string | null> {
  const stmt = env.DB.prepare(
    'SELECT teacher_id FROM auth_tokens WHERE token = ? AND expires_at > datetime("now")'
  );
  const result = await stmt.bind(token).first();
  return result ? result.teacher_id : null;
}

// Hash password (simple - use bcrypt in production)
function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}

// Generate token
function generateToken(): string {
  return crypto.getRandomValues(new Uint8Array(32)).toString();
}

// Register teacher
router.post('/api/teachers/register', async (req: Request, env: Env) => {
  try {
    const { email, password, fullName, schoolName } = await req.json();

    // Validate input
    if (!email || !password || !fullName || !schoolName) {
      return json({ error: 'Missing required fields' }, { status: 400 });
    }

    const teacherId = crypto.randomUUID();
    const passwordHash = hashPassword(password);
    const now = new Date().toISOString();
    const expiresAt = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();

    const stmt = env.DB.prepare(`
      INSERT INTO teachers (
        id, email, password_hash, full_name, school_name,
        license_type, max_students, created_at, license_expires_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    await stmt.bind(
      teacherId,
      email,
      passwordHash,
      fullName,
      schoolName,
      'free',
      5,
      now,
      expiresAt,
      now
    ).run();

    // Generate auth token
    const token = generateToken();
    const tokenId = crypto.randomUUID();
    const tokenExpires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

    const tokenStmt = env.DB.prepare(`
      INSERT INTO auth_tokens (id, teacher_id, token, expires_at, created_at)
      VALUES (?, ?, ?, ?, ?)
    `);
    await tokenStmt.bind(tokenId, teacherId, token, tokenExpires, now).run();

    return json({
      teacher: {
        id: teacherId,
        email,
        fullName,
        schoolName,
        licenseType: 'free',
        maxStudents: 5,
        createdAt: now,
        licenseExpiresAt: expiresAt,
      },
      token,
    }, { status: 201, headers: corsHeaders });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Registration failed' },
      { status: 500, headers: corsHeaders }
    );
  }
});

// Login teacher
router.post('/api/teachers/login', async (req: Request, env: Env) => {
  try {
    const { email, password } = await req.json();

    if (!email || !password) {
      return json({ error: 'Email and password required' }, { status: 400, headers: corsHeaders });
    }

    const passwordHash = hashPassword(password);
    const stmt = env.DB.prepare(
      'SELECT * FROM teachers WHERE email = ? AND password_hash = ?'
    );
    const teacher = await stmt.bind(email, passwordHash).first();

    if (!teacher) {
      return json({ error: 'Invalid credentials' }, { status: 401, headers: corsHeaders });
    }

    // Generate token
    const token = generateToken();
    const tokenId = crypto.randomUUID();
    const now = new Date().toISOString();
    const tokenExpires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

    const tokenStmt = env.DB.prepare(`
      INSERT INTO auth_tokens (id, teacher_id, token, expires_at, created_at)
      VALUES (?, ?, ?, ?, ?)
    `);
    await tokenStmt.bind(tokenId, teacher.id, token, tokenExpires, now).run();

    return json({
      teacher: {
        id: teacher.id,
        email: teacher.email,
        fullName: teacher.full_name,
        schoolName: teacher.school_name,
        licenseType: teacher.license_type,
        maxStudents: teacher.max_students,
        createdAt: teacher.created_at,
        licenseExpiresAt: teacher.license_expires_at,
      },
      token,
    }, { status: 200, headers: corsHeaders });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Login failed' },
      { status: 500, headers: corsHeaders }
    );
  }
});

// Get teacher (protected)
router.get('/api/teachers/:teacherId', async (req: Request, env: Env) => {
  try {
    const authHeader = req.headers.get('Authorization');
    const token = authHeader?.replace('Bearer ', '');

    if (!token) {
      return json({ error: 'Unauthorized' }, { status: 401, headers: corsHeaders });
    }

    const teacherId = await validateToken(token, env);
    if (!teacherId) {
      return json({ error: 'Unauthorized' }, { status: 401, headers: corsHeaders });
    }

    const stmt = env.DB.prepare('SELECT * FROM teachers WHERE id = ?');
    const teacher = await stmt.bind(teacherId).first();

    if (!teacher) {
      return json({ error: 'Teacher not found' }, { status: 404, headers: corsHeaders });
    }

    return json({
      teacher: {
        id: teacher.id,
        email: teacher.email,
        fullName: teacher.full_name,
        schoolName: teacher.school_name,
        licenseType: teacher.license_type,
        maxStudents: teacher.max_students,
        createdAt: teacher.created_at,
        licenseExpiresAt: teacher.license_expires_at,
      },
    }, { status: 200, headers: corsHeaders });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Failed to get teacher' },
      { status: 500, headers: corsHeaders }
    );
  }
});

// Get teacher classes
router.get('/api/teachers/:teacherId/classes', async (req: Request, env: Env) => {
  try {
    const authHeader = req.headers.get('Authorization');
    const token = authHeader?.replace('Bearer ', '');
    const teacherId = await validateToken(token || '', env);

    if (!teacherId) {
      return json({ error: 'Unauthorized' }, { status: 401, headers: corsHeaders });
    }

    const stmt = env.DB.prepare(
      'SELECT * FROM classes WHERE teacher_id = ? AND is_archived = false ORDER BY created_at DESC'
    );
    const classes = await stmt.bind(teacherId).all();

    return json({
      classes: classes.results.map((c: any) => ({
        id: c.id,
        teacherId: c.teacher_id,
        name: c.name,
        gradeLevel: c.grade_level,
        description: c.description,
        createdAt: c.created_at,
        updatedAt: c.updated_at,
        studentIds: [], // Will be populated separately
      })),
    }, { status: 200, headers: corsHeaders });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Failed to get classes' },
      { status: 500, headers: corsHeaders }
    );
  }
});

// Create class
router.post('/api/classes', async (req: Request, env: Env) => {
  try {
    const authHeader = req.headers.get('Authorization');
    const token = authHeader?.replace('Bearer ', '');
    const teacherId = await validateToken(token || '', env);

    if (!teacherId) {
      return json({ error: 'Unauthorized' }, { status: 401, headers: corsHeaders });
    }

    const { name, gradeLevel, description } = await req.json();

    if (!name || gradeLevel === undefined) {
      return json({ error: 'Missing required fields' }, { status: 400, headers: corsHeaders });
    }

    // Check class limit
    const classCountStmt = env.DB.prepare(
      'SELECT COUNT(*) as count FROM classes WHERE teacher_id = ? AND is_archived = false'
    );
    const countResult = await classCountStmt.bind(teacherId).first();
    const classCount = (countResult as any).count;

    if (classCount >= 1) { // Free tier limit
      return json({ error: 'Maximum classes reached' }, { status: 402, headers: corsHeaders });
    }

    const classId = crypto.randomUUID();
    const now = new Date().toISOString();

    const stmt = env.DB.prepare(`
      INSERT INTO classes (id, teacher_id, name, grade_level, description, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

    await stmt.bind(classId, teacherId, name, gradeLevel, description || null, now, now).run();

    return json({
      class: {
        id: classId,
        teacherId,
        name,
        gradeLevel,
        description,
        createdAt: now,
        updatedAt: now,
        studentIds: [],
      },
    }, { status: 201, headers: corsHeaders });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Failed to create class' },
      { status: 500, headers: corsHeaders }
    );
  }
});

// 404
router.all('*', () => status(404));

export default router;
```

---

## Step 7: Deploy

```bash
npm install itty-router itty-router-extras

# Test locally
wrangler dev

# Deploy to production
wrangler publish
```

Your API will be live at: `https://brightbound-api.YOUR_DOMAIN.workers.dev`

---

## Step 8: Update Flutter App

In `pubspec.yaml`, add http package:

```yaml
dependencies:
  http: ^1.1.0
```

Initialize service in your main app:

```dart
// main.dart
final authService = TeacherAuthService(
  apiBase: 'https://brightbound-api.YOUR_DOMAIN.workers.dev',
);

final classService = ClassManagementService(
  apiBase: 'https://brightbound-api.YOUR_DOMAIN.workers.dev',
  authToken: userToken, // From login response
);
```

---

## Step 9: Testing

```bash
# Test registration
curl -X POST https://brightbound-api.workers.dev/api/teachers/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teacher@example.com",
    "password": "password123",
    "fullName": "Ms. Smith",
    "schoolName": "Lincoln Elementary"
  }'

# Test login
curl -X POST https://brightbound-api.workers.dev/api/teachers/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teacher@example.com",
    "password": "password123"
  }'
```

---

## Cost Breakdown

| Usage | Cost |
|-------|------|
| **First 100K requests/month** | Free |
| **Next requests** | $0.15/10K requests |
| **D1 Database** | Free tier (good for 1000+ users) |
| **Custom Domain** | Included (if using Cloudflare domain) |
| **SSL/TLS** | Free |

**Estimate**: At 10K teachers × 100 requests/month = 1M requests = **$15/month** after free tier.

---

## Advantages vs Firebase

| Feature | Firebase | Cloudflare |
|---------|----------|-----------|
| **Cost** | $25/month min | Free to $15/month |
| **Free Tier** | Limited | 100K requests/day |
| **Startup Cost** | Yes | No |
| **Simplicity** | Easy | Medium |
| **Control** | Limited | Full |
| **Migration** | Hard | Easy |

---

## Next: Complete API Endpoints

Current code handles:
- ✅ Register teacher
- ✅ Login teacher
- ✅ Get teacher profile
- ✅ Get teacher's classes
- ✅ Create class

Still needed:
- Add students to class
- Get class students
- Update progress tracking
- License upgrades (with Stripe)
- Password reset

All follow the same pattern - want me to complete them?

---

## Offline-First Strategy

**The key advantage**: Your app works completely offline.

1. Student answers questions → saved to Hive (local)
2. When internet available → sync with Cloudflare
3. Teacher dashboard pulls data from Cloudflare
4. No internet → teacher can't access dashboard, but kids keep learning

This is better than traditional apps because:
- ✅ Zero downtime for kids
- ✅ Works in low-connectivity schools
- ✅ Data syncs automatically when possible
- ✅ Teachers can manage classes online

---

## Ready?

Once you deploy this Cloudflare Workers code, your Flutter app can immediately use the refactored services.

**Next steps**:
1. Create Cloudflare account (free)
2. Deploy D1 database
3. Deploy Worker code
4. Update Flutter app with API endpoint
5. Test registration/login

Want me to create example implementation code for any specific endpoint?
