import { generateToken } from './crypto';
import { AppHonoContext } from '../types';
import { getCookie } from 'hono/cookie';

export interface Session {
  id: string;
  userId: number;
  username: string;
  role: string;
  createdAt: number;
  lastSeenAt: number;
  ip: string;
  userAgent: string;
}

const SESSION_COOKIE_NAME = 'session_id';
const SESSION_DURATION = 30 * 24 * 60 * 60 * 1000; // 30 days

// Create a new session
export async function createSession(
  c: AppHonoContext,
  userId: number,
  username: string,
  role: string
): Promise<string> {
  const sessionId = generateToken(32);
  const now = Date.now();
  const ip = c.req.header('cf-connecting-ip') || c.req.header('x-forwarded-for') || 'unknown';
  const userAgent = c.req.header('user-agent') || 'unknown';

  const session: Session = {
    id: sessionId,
    userId,
    username,
    role,
    createdAt: now,
    lastSeenAt: now,
    ip,
    userAgent,
  };

  // Store in KV (Cloudflare) or memory (Node)
  const env = c.env as any;
  if (env.SESSIONS) {
    await env.SESSIONS.put(`session:${sessionId}`, JSON.stringify(session), {
      expirationTtl: SESSION_DURATION / 1000,
    });
  }

  return sessionId;
}

// Get session from cookie
export async function getSession(c: AppHonoContext): Promise<Session | null> {
  const sessionId = getCookie(c, SESSION_COOKIE_NAME);
  if (!sessionId) return null;

  const env = c.env;
  if (env.SESSIONS) {
    const data = await env.SESSIONS.get(`session:${sessionId}`);
    if (!data) return null;

    const session: Session = JSON.parse(data);
    
    // Update last seen
    session.lastSeenAt = Date.now();
    await env.SESSIONS.put(`session:${sessionId}`, JSON.stringify(session), {
      expirationTtl: SESSION_DURATION / 1000,
    });

    return session;
  }

  return null;
}

// Delete a session
export async function deleteSession(c: AppHonoContext, sessionId?: string): Promise<void> {
  const sid = sessionId || getCookie(c, SESSION_COOKIE_NAME);
  if (!sid) return;

  const env = c.env;
  if (env.SESSIONS) {
    await env.SESSIONS.delete(`session:${sid}`);
  }
}

// Set session cookie
export function setSessionCookie(c: AppHonoContext, sessionId: string): void {
  c.header('Set-Cookie', 
    `${SESSION_COOKIE_NAME}=${sessionId}; Path=/; HttpOnly; SameSite=Lax; Max-Age=${SESSION_DURATION / 1000}`
  );
}

// Clear session cookie
export function clearSessionCookie(c: AppHonoContext): void {
  c.header('Set-Cookie', 
    `${SESSION_COOKIE_NAME}=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0`
  );
}
