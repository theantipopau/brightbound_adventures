import { describe, expect, it } from 'vitest';

import router from '../src/index.js';

// ---------------------------------------------------------------------------
// Minimal in-memory D1 stub: just enough SQL-shape matching for the auth
// routes + schema init. Anything unrecognised throws so new queries fail
// loudly instead of silently passing.
// ---------------------------------------------------------------------------

interface TeacherRow {
  id: string;
  email: string;
  password: string;
  fullName: string;
  schoolName: string;
  licenseType: string;
  maxStudents: number;
}

function createDb() {
  const teachers = new Map<string, TeacherRow>();
  const tokens: Array<{ teacherId: string; token: string; expiresAt: string }> = [];

  return {
    teachers,
    tokens,
    prepare(sql: string) {
      const stmt = {
        params: [] as unknown[],
        bind(...p: unknown[]) {
          (this as { params: unknown[] }).params = p;
          return stmt;
        },
        async first() {
          if (sql.includes('CREATE TABLE') || sql.includes('CREATE INDEX')) {
            return null;
          }
          if (sql.startsWith('SELECT id FROM teachers WHERE email')) {
            const row = teachers.get(stmt.params[0] as string);
            return row ? { id: row.id } : null;
          }
          if (sql.includes('FROM teachers WHERE email = ? AND isActive')) {
            const row = teachers.get(stmt.params[0] as string);
            return row ?? null;
          }
          if (sql.includes('SELECT password FROM teachers WHERE id')) {
            const row = [...teachers.values()].find(t => t.id === stmt.params[0]);
            return row ? { password: row.password } : null;
          }
          throw new Error(`stub: unhandled first(): ${sql}`);
        },
        async run() {
          if (sql.includes('CREATE TABLE') || sql.includes('CREATE INDEX')) {
            return { success: true };
          }
          if (sql.includes('INSERT INTO teachers')) {
            const [id, email, password, fullName, schoolName] = stmt.params as string[];
            teachers.set(email, {
              id,
              email,
              password,
              fullName,
              schoolName,
              licenseType: 'free',
              maxStudents: 5,
            });
            return { success: true };
          }
          if (sql.includes('INSERT INTO auth_tokens')) {
            const [, teacherId, token, expiresAt] = stmt.params as string[];
            tokens.push({ teacherId, token, expiresAt });
            return { success: true };
          }
          throw new Error(`stub: unhandled run(): ${sql}`);
        },
        async all() {
          return { results: [] };
        },
      };
      return stmt;
    },
  };
}

type StubDb = ReturnType<typeof createDb>;

function post(path: string, body: unknown, ip = '9.9.9.9'): Request {
  return new Request(`http://test${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'CF-Connecting-IP': ip },
    body: JSON.stringify(body),
  });
}

async function handle(db: StubDb, req: Request): Promise<Response> {
  const handler = (router as unknown as { handle: (r: Request, e: unknown) => Promise<Response> })
    .handle;
  return handler.call(router, req, { DB: db });
}

const validReg = {
  email: 'teacher@school.edu',
  password: 'supersecretpassword',
  fullName: 'Test Teacher',
  schoolName: 'Test School',
};

describe('auth validation', () => {
  it('register rejects missing fields with 400', async () => {
    const res = await handle(createDb(), post('/api/teachers/register', { email: 'a@b.c' }));
    expect(res.status).toBe(400);
  });

  it('register rejects short passwords with 400', async () => {
    const res = await handle(
      createDb(),
      post('/api/teachers/register', { ...validReg, password: 'short' }),
    );
    expect(res.status).toBe(400);
  });

  it('register succeeds and login accepts the new credentials', async () => {
    const db = createDb();
    const reg = await handle(db, post('/api/teachers/register', validReg));
    expect(reg.status).toBe(201);
    const regBody = (await reg.json()) as { token: string };
    expect(regBody.token).toBeTruthy();

    const login = await handle(
      db,
      post('/api/teachers/login', { email: validReg.email, password: validReg.password }),
    );
    expect(login.status).toBe(200);
  });

  it('register rejects duplicate email with 409', async () => {
    const db = createDb();
    expect((await handle(db, post('/api/teachers/register', validReg))).status).toBe(201);
    const dup = await handle(db, post('/api/teachers/register', validReg));
    expect(dup.status).toBe(409);
  });

  it('login rejects wrong password with 401 (no user-or-password oracle)', async () => {
    const db = createDb();
    await handle(db, post('/api/teachers/register', validReg));
    const bad = await handle(
      db,
      post('/api/teachers/login', { email: validReg.email, password: 'wrongpassword1' }),
    );
    expect(bad.status).toBe(401);
    const unknown = await handle(
      db,
      post('/api/teachers/login', { email: 'nobody@school.edu', password: 'wrongpassword1' }),
    );
    expect(unknown.status).toBe(401);
  });
});

describe('auth rate limiting', () => {
  it('429s the 11th rapid register attempt from one IP', async () => {
    const db = createDb();
    let last = 0;
    for (let i = 0; i < 11; i++) {
      const res = await handle(
        db,
        post('/api/teachers/register', { ...validReg, email: `t${i}@school.edu` }),
      );
      last = res.status;
    }
    expect(last).toBe(429);
  });

  it('reset-password-request stays generic (anti-enumeration)', async () => {
    // Fresh IP: the limiter is module-level, and earlier tests in this
    // file already spent the shared test IP's auth budget (by design).
    const res = await handle(
      createDb(),
      post('/api/teachers/reset-password-request', { email: 'ghost@school.edu' }, '8.8.8.8'),
    );
    expect(res.status).toBe(200);
    const body = (await res.json()) as { success: boolean };
    expect(body.success).toBe(true);
  });
});
