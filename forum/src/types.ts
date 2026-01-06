import { Context } from 'hono';
import { Session } from './security/session';

// Cloudflare D1 Database bindings
export interface Env {
  DB: D1Database;
  SESSIONS: KVNamespace;
  RATELIMIT: KVNamespace;
  DEPLOY_TARGET?: string;
}

// User object stored in context after authentication
export interface AuthUser {
  id: number;
  username: string;
  role: string;
}

// Extended context with custom variables
export interface AppContext {
  Variables: {
    user?: AuthUser | null;
    session?: Session | null;
    csrfToken?: string;
  };
  Bindings: Env;
}

// Typed Hono context
export type AppHonoContext = Context<AppContext>;
