import { generateToken, hashToken } from './crypto';
import { AppHonoContext } from '../types';
import { getCookie } from 'hono/cookie';

const CSRF_TOKEN_NAME = 'csrf_token';

// Generate and store CSRF token
export async function generateCSRFToken(c: AppHonoContext): Promise<string> {
  const token = generateToken(32);
  const tokenHash = await hashToken(token);
  
  // Store hash in session or cookie
  c.header('Set-Cookie', 
    `${CSRF_TOKEN_NAME}=${tokenHash}; Path=/; HttpOnly; SameSite=Lax; Max-Age=3600`
  );
  
  return token;
}

// Verify CSRF token
export async function verifyCSRFToken(c: AppHonoContext, token: string | undefined): Promise<boolean> {
  if (!token) return false;
  
  const storedHash = getCookie(c, CSRF_TOKEN_NAME);
  if (!storedHash) return false;
  
  const tokenHash = await hashToken(token);
  return tokenHash === storedHash;
}

// Middleware to check CSRF on POST/PUT/DELETE
export async function csrfMiddleware(c: AppHonoContext, next: () => Promise<void>): Promise<void | Response> {
  const method = c.req.method;
  
  if (['POST', 'PUT', 'DELETE'].includes(method)) {
    // Get token from form data or header
    let token: string | undefined;
    
    const contentType = c.req.header('content-type') || '';
    if (contentType.includes('application/x-www-form-urlencoded') || contentType.includes('multipart/form-data')) {
      const formData = await c.req.formData();
      token = formData.get('csrf_token') as string;
    } else {
      token = c.req.header('x-csrf-token');
    }
    
    const isValid = await verifyCSRFToken(c, token);
    if (!isValid) {
      return c.text('CSRF token validation failed', 403);
    }
  }
  
  await next();
}
