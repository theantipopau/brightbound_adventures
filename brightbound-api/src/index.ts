/// <reference types="@cloudflare/workers-types" />

import { Router } from 'itty-router';

interface Env {
  DB: D1Database;
}

const router = Router();

// ============================================================================
// CORS Configuration
// ============================================================================
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};

router.options('*', () => {
  return new Response(null, { headers: corsHeaders });
});

// ============================================================================
// Helper Functions
// ============================================================================

function addCorsHeaders(response: Response): Response {
  const newResponse = new Response(response.body, response);
  Object.entries(corsHeaders).forEach(([key, value]) => {
    newResponse.headers.set(key, value);
  });
  return newResponse;
}

function jsonResponse(data: any, status = 200): Response {
  return addCorsHeaders(
    new Response(JSON.stringify(data), {
      status,
      headers: { 'Content-Type': 'application/json' },
    })
  );
}

function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ error: message }, status);
}

async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(password),
    'PBKDF2',
    false,
    ['deriveBits'],
  );
  const hashBuffer = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100_000, hash: 'SHA-256' },
    keyMaterial,
    256,
  );
  const saltHex = Array.from(salt).map(b => b.toString(16).padStart(2, '0')).join('');
  const hashHex = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('');
  return `${saltHex}:${hashHex}`;
}

async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const colonIdx = stored.indexOf(':');
  if (colonIdx === -1) return false;
  const saltHex = stored.slice(0, colonIdx);
  const hashHex = stored.slice(colonIdx + 1);
  const saltBytes = saltHex.match(/.{2}/g);
  if (!saltBytes) return false;
  const salt = new Uint8Array(saltBytes.map(b => parseInt(b, 16)));
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(password),
    'PBKDF2',
    false,
    ['deriveBits'],
  );
  const hashBuffer = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', salt, iterations: 100_000, hash: 'SHA-256' },
    keyMaterial,
    256,
  );
  const computedHex = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('');
  return timingSafeEqual(computedHex, hashHex);
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

function generateToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(48));
  return Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
}

function generateUUID(): string {
  return crypto.randomUUID();
}

async function getAuthorizedTeacherId(env: Env, token?: string | null): Promise<string | null> {
  if (!token) return null;
  const authToken = await env.DB.prepare(
    'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
  ).bind(token, new Date().toISOString()).first() as any;
  return authToken?.teacherId ?? null;
}

async function getClassWithStudentCount(
  env: Env,
  classId: string,
  teacherId: string,
): Promise<any | null> {
  const classData = await env.DB.prepare(
    `SELECT c.id, c.teacherId, c.name, c.gradeLevel, c.subject, c.description, c.isArchived, c.createdAt, c.updatedAt,
            COUNT(ce.studentId) as studentCount
     FROM classes c
     LEFT JOIN class_enrollments ce ON c.id = ce.classId
     WHERE c.id = ? AND c.teacherId = ?
     GROUP BY c.id`
  ).bind(classId, teacherId).first();

  return classData ?? null;
}

// ============================================================================
// Database Schema Initialization
// ============================================================================

async function initializeDatabase(db: D1Database): Promise<void> {
  // Create tables if they don't exist
  const schema = `
    CREATE TABLE IF NOT EXISTS teachers (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      fullName TEXT NOT NULL,
      schoolName TEXT NOT NULL,
      schoolDistrict TEXT,
      gradeSpecialty TEXT,
      phoneNumber TEXT,
      licenseType TEXT DEFAULT 'free' CHECK(licenseType IN ('free', 'premium', 'enterprise')),
      maxStudents INTEGER DEFAULT 5,
      isActive BOOLEAN DEFAULT true,
      createdAt TEXT NOT NULL,
      licenseExpiresAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS auth_tokens (
      id TEXT PRIMARY KEY,
      teacherId TEXT NOT NULL,
      token TEXT UNIQUE NOT NULL,
      expiresAt TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (teacherId) REFERENCES teachers(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS classes (
      id TEXT PRIMARY KEY,
      teacherId TEXT NOT NULL,
      name TEXT NOT NULL,
      gradeLevel TEXT,
      subject TEXT,
      description TEXT,
      isArchived BOOLEAN DEFAULT false,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      FOREIGN KEY (teacherId) REFERENCES teachers(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS class_enrollments (
      id TEXT PRIMARY KEY,
      classId TEXT NOT NULL,
      studentId TEXT NOT NULL,
      enrolledAt TEXT NOT NULL,
      FOREIGN KEY (classId) REFERENCES classes(id) ON DELETE CASCADE,
      UNIQUE(classId, studentId)
    );

    CREATE TABLE IF NOT EXISTS student_progress (
      id TEXT PRIMARY KEY,
      studentId TEXT NOT NULL,
      classId TEXT,
      questionsAnswered INTEGER DEFAULT 0,
      correctAnswers INTEGER DEFAULT 0,
      currentStreak INTEGER DEFAULT 0,
      lastActiveDate TEXT,
      updatedAt TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);
    CREATE INDEX IF NOT EXISTS idx_classes_teacherId ON classes(teacherId);
    CREATE INDEX IF NOT EXISTS idx_auth_tokens_teacherId ON auth_tokens(teacherId);
    CREATE INDEX IF NOT EXISTS idx_auth_tokens_token ON auth_tokens(token);
    CREATE INDEX IF NOT EXISTS idx_class_enrollments_classId ON class_enrollments(classId);
    CREATE INDEX IF NOT EXISTS idx_student_progress_studentId ON student_progress(studentId);
  `;

  // Execute schema creation
  for (const stmt of schema.split(';').filter(s => s.trim())) {
    try {
      await db.prepare(stmt).run();
    } catch (e) {
      // Tables may already exist, ignore errors
    }
  }
}

// ============================================================================
// Authentication Routes
// ============================================================================

// Register Teacher
router.post('/api/teachers/register', async (req: any, env: Env) => {
  try {
    const { email, password, fullName, schoolName, schoolDistrict, gradeSpecialty, phoneNumber } = await req.json();

    // Validation
    if (!email || !password || !fullName || !schoolName) {
      return errorResponse('Missing required fields', 400);
    }
    if (String(password).length < 10) {
      return errorResponse('Password must be at least 10 characters', 400);
    }

    await initializeDatabase(env.DB);

    // Check if teacher exists
    const existing = await env.DB.prepare(
      'SELECT id FROM teachers WHERE email = ?'
    ).bind(email).first();

    if (existing) {
      return errorResponse('Teacher already exists with this email', 409);
    }

    const teacherId = generateUUID();
    const hashedPassword = await hashPassword(password);
    const now = new Date().toISOString();
    const expiresAt = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(); // 1 year

    // Insert teacher
    await env.DB.prepare(`
      INSERT INTO teachers (id, email, password, fullName, schoolName, schoolDistrict, gradeSpecialty, phoneNumber, createdAt, updatedAt, licenseExpiresAt)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(teacherId, email, hashedPassword, fullName, schoolName, schoolDistrict || null, gradeSpecialty || null, phoneNumber || null, now, now, expiresAt).run();

    // Generate token
    const token = generateToken();
    const tokenId = generateUUID();
    const tokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(); // 7 days

    await env.DB.prepare(`
      INSERT INTO auth_tokens (id, teacherId, token, expiresAt, createdAt)
      VALUES (?, ?, ?, ?, ?)
    `).bind(tokenId, teacherId, token, tokenExpiresAt, now).run();

    return jsonResponse({
      teacher: {
        id: teacherId,
        email,
        fullName,
        schoolName,
        schoolDistrict,
        gradeSpecialty,
        phoneNumber,
        licenseType: 'free',
        maxStudents: 5,
        createdAt: now,
        licenseExpiresAt: expiresAt,
      },
      token,
    }, 201);
  } catch (error: any) {
    console.error('Registration error:', error);
    return errorResponse(error.message || 'Registration failed', 500);
  }
});

// Login Teacher
router.post('/api/teachers/login', async (req: any, env: Env) => {
  try {
    const { email, password } = await req.json();

    if (!email || !password) {
      return errorResponse('Email and password required', 400);
    }

    await initializeDatabase(env.DB);

    const teacher = await env.DB.prepare(
      'SELECT id, email, password, fullName, schoolName, licenseType, maxStudents FROM teachers WHERE email = ? AND isActive = true'
    ).bind(email).first();

    if (!teacher) {
      return errorResponse('Invalid email or password', 401);
    }

    if (!(await verifyPassword(password, teacher.password as string))) {
      return errorResponse('Invalid email or password', 401);
    }

    // Generate token
    const token = generateToken();
    const tokenId = generateUUID();
    const now = new Date().toISOString();
    const tokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

    await env.DB.prepare(`
      INSERT INTO auth_tokens (id, teacherId, token, expiresAt, createdAt)
      VALUES (?, ?, ?, ?, ?)
    `).bind(tokenId, teacher.id, token, tokenExpiresAt, now).run();

    return jsonResponse({
      teacher: {
        id: teacher.id,
        email: teacher.email,
        fullName: teacher.fullName,
        schoolName: teacher.schoolName,
        licenseType: teacher.licenseType,
        maxStudents: teacher.maxStudents,
      },
      token,
    });
  } catch (error: any) {
    console.error('Login error:', error);
    return errorResponse(error.message || 'Login failed', 500);
  }
});

// Get Current Teacher
router.get('/api/teachers/:teacherId', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken || authToken.teacherId !== req.params.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const teacher = await env.DB.prepare(
      'SELECT id, email, fullName, schoolName, licenseType, maxStudents, createdAt, licenseExpiresAt FROM teachers WHERE id = ?'
    ).bind(req.params.teacherId).first();

    if (!teacher) {
      return errorResponse('Teacher not found', 404);
    }

    return jsonResponse({ teacher });
  } catch (error: any) {
    console.error('Get teacher error:', error);
    return errorResponse(error.message || 'Failed to get teacher', 500);
  }
});

router.patch('/api/teachers/:teacherId', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const teacherId = await getAuthorizedTeacherId(env, token);
    if (!teacherId || teacherId !== req.params.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const { fullName, phoneNumber, schoolDistrict, gradeSpecialty } = await req.json();

    const updates: string[] = [];
    const values: any[] = [];

    if (fullName !== undefined) {
      updates.push('fullName = ?');
      values.push(fullName);
    }
    if (phoneNumber !== undefined) {
      updates.push('phoneNumber = ?');
      values.push(phoneNumber || null);
    }
    if (schoolDistrict !== undefined) {
      updates.push('schoolDistrict = ?');
      values.push(schoolDistrict || null);
    }
    if (gradeSpecialty !== undefined) {
      updates.push('gradeSpecialty = ?');
      values.push(gradeSpecialty || null);
    }

    if (updates.length === 0) {
      return errorResponse('No fields to update', 400);
    }

    updates.push('updatedAt = ?');
    values.push(new Date().toISOString());
    values.push(req.params.teacherId);

    await env.DB.prepare(
      `UPDATE teachers SET ${updates.join(', ')} WHERE id = ?`
    ).bind(...values).run();

    const teacher = await env.DB.prepare(
      'SELECT id, email, fullName, schoolName, schoolDistrict, gradeSpecialty, phoneNumber, licenseType, maxStudents, createdAt, licenseExpiresAt FROM teachers WHERE id = ?'
    ).bind(req.params.teacherId).first();

    if (!teacher) {
      return errorResponse('Teacher not found', 404);
    }

    return jsonResponse({ teacher });
  } catch (error: any) {
    console.error('Update teacher profile error:', error);
    return errorResponse(error.message || 'Failed to update teacher profile', 500);
  }
});

router.post('/api/teachers/:teacherId/change-password', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const teacherId = await getAuthorizedTeacherId(env, token);
    if (!teacherId || teacherId !== req.params.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const { currentPassword, newPassword } = await req.json();
    if (!currentPassword || !newPassword) {
      return errorResponse('Current password and new password are required', 400);
    }
    if (String(newPassword).length < 10) {
      return errorResponse('New password must be at least 10 characters', 400);
    }

    const teacher = await env.DB.prepare(
      'SELECT password FROM teachers WHERE id = ? AND isActive = true'
    ).bind(req.params.teacherId).first() as any;

    if (!teacher) {
      return errorResponse('Teacher not found', 404);
    }

    if (!(await verifyPassword(currentPassword, teacher.password as string))) {
      return errorResponse('Current password is incorrect', 401);
    }

    const hashedPassword = await hashPassword(newPassword);
    await env.DB.prepare(
      'UPDATE teachers SET password = ?, updatedAt = ? WHERE id = ?'
    ).bind(hashedPassword, new Date().toISOString(), req.params.teacherId).run();

    return jsonResponse({ success: true });
  } catch (error: any) {
    console.error('Change password error:', error);
    return errorResponse(error.message || 'Failed to change password', 500);
  }
});

router.post('/api/teachers/reset-password-request', async (req: any) => {
  try {
    const { email } = await req.json();
    if (!email) {
      return errorResponse('Email is required', 400);
    }

    return jsonResponse({
      success: true,
      message: 'If an account exists for that email, a reset email has been sent.',
    });
  } catch (error: any) {
    console.error('Reset password request error:', error);
    return errorResponse(error.message || 'Failed to process reset password request', 500);
  }
});

router.post('/api/teachers/:teacherId/upgrade-license', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const teacherId = await getAuthorizedTeacherId(env, token);
    if (!teacherId || teacherId !== req.params.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const { licenseType } = await req.json();
    const normalized = String(licenseType ?? '').toLowerCase();
    if (!['free', 'premium', 'enterprise'].includes(normalized)) {
      return errorResponse('Invalid license type', 400);
    }

    const maxStudentsByLicense: Record<string, number> = {
      free: 5,
      premium: 30,
      enterprise: 200,
    };

    await env.DB.prepare(
      'UPDATE teachers SET licenseType = ?, maxStudents = ?, updatedAt = ? WHERE id = ?'
    ).bind(
      normalized,
      maxStudentsByLicense[normalized],
      new Date().toISOString(),
      req.params.teacherId,
    ).run();

    const teacher = await env.DB.prepare(
      'SELECT id, email, fullName, schoolName, schoolDistrict, gradeSpecialty, phoneNumber, licenseType, maxStudents, createdAt, licenseExpiresAt FROM teachers WHERE id = ?'
    ).bind(req.params.teacherId).first();

    if (!teacher) {
      return errorResponse('Teacher not found', 404);
    }

    return jsonResponse({ teacher });
  } catch (error: any) {
    console.error('Upgrade license error:', error);
    return errorResponse(error.message || 'Failed to upgrade license', 500);
  }
});

// ============================================================================
// Class Routes
// ============================================================================

// Create Class
router.post('/api/classes', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    const { name, gradeLevel, subject, description } = await req.json();

    if (!name) {
      return errorResponse('Class name required', 400);
    }

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken) {
      return errorResponse('Unauthorized', 403);
    }

    const teacherId = authToken.teacherId;

    const teacher = await env.DB.prepare(
      'SELECT licenseType, maxStudents FROM teachers WHERE id = ?'
    ).bind(teacherId).first() as any;

    const existingClasses = await env.DB.prepare(
      'SELECT COUNT(*) as count FROM classes WHERE teacherId = ? AND isArchived = false'
    ).bind(teacherId).first() as any;

    const classCount = (existingClasses as any)?.count || 0;
    const maxClasses = (teacher as any)?.licenseType === 'free' ? 1 : (teacher as any)?.licenseType === 'premium' ? 10 : 999;

    if (classCount >= maxClasses) {
      return errorResponse(`Maximum ${maxClasses} classes reached for your license type`, 402);
    }

    const classId = generateUUID();
    const now = new Date().toISOString();

    await env.DB.prepare(`
      INSERT INTO classes (id, teacherId, name, gradeLevel, subject, description, createdAt, updatedAt)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(classId, teacherId, name, gradeLevel || null, subject || null, description || null, now, now).run();

    return jsonResponse({
      class: {
        id: classId,
        teacherId,
        name,
        gradeLevel,
        subject,
        description,
        studentCount: 0,
        createdAt: now,
      },
    }, 201);
  } catch (error: any) {
    console.error('Create class error:', error);
    return errorResponse(error.message || 'Failed to create class', 500);
  }
});

// Get Teacher Classes
router.get('/api/teachers/:teacherId/classes', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken || authToken.teacherId !== req.params.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const classes = await env.DB.prepare(
      `SELECT c.id, c.name, c.gradeLevel, c.subject, c.description, c.createdAt,
              COUNT(ce.studentId) as studentCount
       FROM classes c
       LEFT JOIN class_enrollments ce ON c.id = ce.classId
       WHERE c.teacherId = ? AND c.isArchived = false
       GROUP BY c.id
       ORDER BY c.createdAt DESC`
    ).bind(req.params.teacherId).all() as any;

    return jsonResponse({ classes: classes?.results || [] });
  } catch (error: any) {
    console.error('Get classes error:', error);
    return errorResponse(error.message || 'Failed to get classes', 500);
  }
});

// Get Class
router.get('/api/classes/:classId', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken) {
      return errorResponse('Unauthorized', 403);
    }

    const classData = await env.DB.prepare(
      `SELECT c.*, COUNT(ce.studentId) as studentCount
       FROM classes c
       LEFT JOIN class_enrollments ce ON c.id = ce.classId
       WHERE c.id = ? AND c.teacherId = ?
       GROUP BY c.id`
    ).bind(req.params.classId, authToken.teacherId).first();

    if (!classData) {
      return errorResponse('Class not found', 404);
    }

    return jsonResponse({ class: classData });
  } catch (error: any) {
    console.error('Get class error:', error);
    return errorResponse(error.message || 'Failed to get class', 500);
  }
});

// Update Class
router.patch('/api/classes/:classId', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    const { name, gradeLevel, subject, description } = await req.json();

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken) {
      return errorResponse('Unauthorized', 403);
    }

    const classData = await env.DB.prepare(
      'SELECT teacherId FROM classes WHERE id = ?'
    ).bind(req.params.classId).first();

    if (!classData || classData.teacherId !== authToken.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const now = new Date().toISOString();
    const updates = [];
    const values = [];

    if (name) {
      updates.push('name = ?');
      values.push(name);
    }
    if (gradeLevel) {
      updates.push('gradeLevel = ?');
      values.push(gradeLevel);
    }
    if (subject) {
      updates.push('subject = ?');
      values.push(subject);
    }
    if (description !== undefined) {
      updates.push('description = ?');
      values.push(description);
    }

    if (updates.length === 0) {
      return errorResponse('No fields to update', 400);
    }

    updates.push('updatedAt = ?');
    values.push(now);
    values.push(req.params.classId);

    await env.DB.prepare(
      `UPDATE classes SET ${updates.join(', ')} WHERE id = ?`
    ).bind(...values).run();

    const updatedClass = await getClassWithStudentCount(env, req.params.classId, authToken.teacherId);
    if (!updatedClass) {
      return errorResponse('Class not found', 404);
    }

    return jsonResponse({ class: updatedClass });
  } catch (error: any) {
    console.error('Update class error:', error);
    return errorResponse(error.message || 'Failed to update class', 500);
  }
});

// Add Student to Class
router.post('/api/classes/:classId/students', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    const { studentId } = await req.json();

    if (!studentId) {
      return errorResponse('Student ID required', 400);
    }

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken) {
      return errorResponse('Unauthorized', 403);
    }

    const classData = await env.DB.prepare(
      'SELECT teacherId FROM classes WHERE id = ?'
    ).bind(req.params.classId).first();

    if (!classData || classData.teacherId !== authToken.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const teacher = await env.DB.prepare(
      'SELECT maxStudents FROM teachers WHERE id = ?'
    ).bind((authToken as any).teacherId).first() as any;

    const students = await env.DB.prepare(
      'SELECT COUNT(*) as count FROM class_enrollments WHERE classId = ?'
    ).bind(req.params.classId).first() as any;

    const studentCount = (students as any)?.count || 0;
    if (studentCount >= (teacher as any)?.maxStudents) {
      return errorResponse(`Maximum ${(teacher as any)?.maxStudents} students reached for this class`, 402);
    }

    const enrollmentId = generateUUID();
    const now = new Date().toISOString();

    try {
      await env.DB.prepare(`
        INSERT INTO class_enrollments (id, classId, studentId, enrolledAt)
        VALUES (?, ?, ?, ?)
      `).bind(enrollmentId, req.params.classId, studentId, now).run();
    } catch (e: any) {
      if (e.message?.includes('UNIQUE')) {
        return errorResponse('Student already enrolled in this class', 409);
      }
      throw e;
    }

    const updatedClass = await getClassWithStudentCount(env, req.params.classId, authToken.teacherId);
    if (!updatedClass) {
      return errorResponse('Class not found', 404);
    }

    return jsonResponse({ class: updatedClass });
  } catch (error: any) {
    console.error('Add student error:', error);
    return errorResponse(error.message || 'Failed to add student', 500);
  }
});

// Remove Student from Class
router.delete('/api/classes/:classId/students/:studentId', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const authToken = await env.DB.prepare(
      'SELECT teacherId FROM auth_tokens WHERE token = ? AND expiresAt > ?'
    ).bind(token, new Date().toISOString()).first();

    if (!authToken) {
      return errorResponse('Unauthorized', 403);
    }

    const classData = await env.DB.prepare(
      'SELECT teacherId FROM classes WHERE id = ?'
    ).bind(req.params.classId).first();

    if (!classData || classData.teacherId !== authToken.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    await env.DB.prepare(
      'DELETE FROM class_enrollments WHERE classId = ? AND studentId = ?'
    ).bind(req.params.classId, req.params.studentId).run();

    const updatedClass = await getClassWithStudentCount(env, req.params.classId, authToken.teacherId);
    if (!updatedClass) {
      return errorResponse('Class not found', 404);
    }

    return jsonResponse({ class: updatedClass });
  } catch (error: any) {
    console.error('Remove student error:', error);
    return errorResponse(error.message || 'Failed to remove student', 500);
  }
});

router.post('/api/classes/:classId/archive', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const teacherId = await getAuthorizedTeacherId(env, token);
    if (!teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const classData = await env.DB.prepare(
      'SELECT id FROM classes WHERE id = ? AND teacherId = ?'
    ).bind(req.params.classId, teacherId).first();

    if (!classData) {
      return errorResponse('Class not found', 404);
    }

    await env.DB.prepare(
      'UPDATE classes SET isArchived = true, updatedAt = ? WHERE id = ?'
    ).bind(new Date().toISOString(), req.params.classId).run();

    return jsonResponse({ success: true });
  } catch (error: any) {
    console.error('Archive class error:', error);
    return errorResponse(error.message || 'Failed to archive class', 500);
  }
});

router.post('/api/classes/:classId/students/bulk', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const teacherId = await getAuthorizedTeacherId(env, token);
    if (!teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const { studentIds } = await req.json();
    if (!Array.isArray(studentIds) || studentIds.length === 0) {
      return errorResponse('studentIds must be a non-empty array', 400);
    }

    const classData = await env.DB.prepare(
      'SELECT id FROM classes WHERE id = ? AND teacherId = ?'
    ).bind(req.params.classId, teacherId).first();

    if (!classData) {
      return errorResponse('Class not found', 404);
    }

    const teacher = await env.DB.prepare(
      'SELECT maxStudents FROM teachers WHERE id = ?'
    ).bind(teacherId).first() as any;

    const students = await env.DB.prepare(
      'SELECT COUNT(*) as count FROM class_enrollments WHERE classId = ?'
    ).bind(req.params.classId).first() as any;

    const maxStudents = Number((teacher as any)?.maxStudents ?? 0);
    const currentCount = Number((students as any)?.count ?? 0);
    const uniqueIncoming = Array.from(new Set(studentIds.map((id: any) => String(id))));

    if (currentCount + uniqueIncoming.length > maxStudents) {
      return errorResponse('Cannot add all students - would exceed capacity', 402);
    }

    const now = new Date().toISOString();
    for (const studentId of uniqueIncoming) {
      await env.DB.prepare(
        'INSERT OR IGNORE INTO class_enrollments (id, classId, studentId, enrolledAt) VALUES (?, ?, ?, ?)'
      ).bind(generateUUID(), req.params.classId, studentId, now).run();
    }

    const updatedClass = await getClassWithStudentCount(env, req.params.classId, teacherId);
    if (!updatedClass) {
      return errorResponse('Class not found', 404);
    }

    return jsonResponse({ class: updatedClass });
  } catch (error: any) {
    console.error('Bulk add students error:', error);
    return errorResponse(error.message || 'Failed to bulk add students', 500);
  }
});

router.get('/api/teachers/:teacherId/classes/archived', async (req: any, env: Env) => {
  try {
    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return errorResponse('Authorization required', 401);
    }

    await initializeDatabase(env.DB);

    const teacherId = await getAuthorizedTeacherId(env, token);
    if (!teacherId || teacherId !== req.params.teacherId) {
      return errorResponse('Unauthorized', 403);
    }

    const classes = await env.DB.prepare(
      `SELECT c.id, c.teacherId, c.name, c.gradeLevel, c.subject, c.description, c.createdAt, c.updatedAt,
              COUNT(ce.studentId) as studentCount
       FROM classes c
       LEFT JOIN class_enrollments ce ON c.id = ce.classId
       WHERE c.teacherId = ? AND c.isArchived = true
       GROUP BY c.id
       ORDER BY c.updatedAt DESC`
    ).bind(req.params.teacherId).all() as any;

    return jsonResponse({ classes: classes?.results || [] });
  } catch (error: any) {
    console.error('Get archived classes error:', error);
    return errorResponse(error.message || 'Failed to get archived classes', 500);
  }
});

// ============================================================================
// 404 Handler
// ============================================================================

router.all('*', () => {
  return errorResponse('Not found', 404);
});

export default router;
