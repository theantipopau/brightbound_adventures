import { serve } from '@hono/node-server';
import { serveStatic } from '@hono/node-server/serve-static';
import app from './src/app';
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as schema from './src/db/schema';
import { loadTemplates } from './src/templates/loader';

// Load templates for Node.js mode
loadTemplates();

const PORT = process.env.PORT || 3000;

// Create SQLite database
const sqlite = new Database('./forum.db');
const db = drizzle(sqlite, { schema });

// In-memory session storage for Node mode
const sessions = new Map<string, any>();

// Mock KV for local development
const mockKV = {
  async get(key: string) {
    return sessions.get(key) || null;
  },
  async put(key: string, value: string, options?: any) {
    sessions.set(key, value);
  },
  async delete(key: string) {
    sessions.delete(key);
  },
};

// Mock D1 for local development
const mockD1: any = {
  prepare: (sql: string) => {
    const stmt = sqlite.prepare(sql);
    return {
      bind: (...params: any[]) => {
        return {
          run: () => stmt.run(...params),
          all: () => stmt.all(...params),
          first: () => stmt.get(...params),
        };
      },
      run: () => stmt.run(),
      all: () => stmt.all(),
      first: () => stmt.get(),
    };
  },
  dump: () => Promise.resolve(new ArrayBuffer(0)),
  batch: (statements: any[]) => {
    return Promise.all(statements.map((s: any) => s.run()));
  },
  exec: (sql: string) => {
    sqlite.exec(sql);
    return Promise.resolve({ count: 0, duration: 0 });
  },
};

// Wrap app with environment bindings
const wrappedApp = app.use('*', async (c, next) => {
  // Inject mock bindings for Node.js environment
  (c.env as any).DB = mockD1;
  (c.env as any).SESSIONS = mockKV;
  (c.env as any).RATELIMIT = mockKV;
  (c.env as any).DEPLOY_TARGET = 'node';
  await next();
});

// Serve static files
wrappedApp.use('/css/*', serveStatic({ root: './public' }));
wrappedApp.use('/img/*', serveStatic({ root: './public' }));
wrappedApp.use('/js/*', serveStatic({ root: './public' }));

console.log(`
🚀 BrightBound Adventures Forum (Node.js mode)
📍 Server starting on http://localhost:${PORT}

Admin credentials:
  Username: admin
  Password: AdminPass!234

Moderator credentials:
  Username: moderator
  Password: ModPass!234

Make sure to run migrations first:
  npm run db:migrate:local
  npm run db:seed:local
`);

serve({
  fetch: wrappedApp.fetch,
  port: Number(PORT),
});
