import { getSession, Session } from '../security/session';
import { AppHonoContext } from '../types';

// Add user and session to context
export async function authMiddleware(c: AppHonoContext, next: () => Promise<void>): Promise<void> {
  const session = await getSession(c);
  c.set('session', session);
  c.set('user', session ? { id: session.userId, username: session.username, role: session.role } : null);
  await next();
}

// Require authentication
export async function requireAuth(c: AppHonoContext, next: () => Promise<void>): Promise<void | Response> {
  const user = c.get('user');
  if (!user) {
    return c.redirect('/login?redirect=' + encodeURIComponent(c.req.url));
  }
  await next();
}

// Require specific role
export function requireRole(role: 'admin' | 'moderator') {
  return async (c: AppHonoContext, next: () => Promise<void>): Promise<void | Response> => {
    const user = c.get('user');
    if (!user) {
      return c.redirect('/login?redirect=' + encodeURIComponent(c.req.url));
    }
    
    if (role === 'admin' && user.role !== 'admin') {
      return c.text('Forbidden: Admin access required', 403);
    }
    
    if (role === 'moderator' && user.role !== 'moderator' && user.role !== 'admin') {
      return c.text('Forbidden: Moderator access required', 403);
    }
    
    await next();
  };
}

// Check if user can moderate (moderator or admin)
export function canModerate(user: any): boolean {
  return user && (user.role === 'admin' || user.role === 'moderator');
}

// Check if user is admin
export function isAdmin(user: any): boolean {
  return user && user.role === 'admin';
}
