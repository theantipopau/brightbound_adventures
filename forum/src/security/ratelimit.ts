import { Context } from 'hono';

interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
}

const RATE_LIMITS: Record<string, RateLimitConfig> = {
  login: { windowMs: 15 * 60 * 1000, maxRequests: 5 }, // 5 attempts per 15 min
  register: { windowMs: 60 * 60 * 1000, maxRequests: 3 }, // 3 per hour
  post: { windowMs: 60 * 1000, maxRequests: 10 }, // 10 posts per minute
  pm: { windowMs: 60 * 1000, maxRequests: 5 }, // 5 PMs per minute
  search: { windowMs: 60 * 1000, maxRequests: 20 }, // 20 searches per minute
};

export async function checkRateLimit(
  c: Context,
  action: keyof typeof RATE_LIMITS,
  identifier?: string
): Promise<boolean> {
  const config = RATE_LIMITS[action];
  const ip = identifier || c.req.header('cf-connecting-ip') || c.req.header('x-forwarded-for') || 'unknown';
  const key = `ratelimit:${action}:${ip}`;
  
  const env = c.env as any;
  if (!env.RATELIMIT) {
    // If no KV available, allow (for local dev)
    return true;
  }

  const now = Date.now();
  const data = await env.RATELIMIT.get(key);
  
  let requests: number[] = data ? JSON.parse(data) : [];
  
  // Remove expired timestamps
  requests = requests.filter(ts => now - ts < config.windowMs);
  
  if (requests.length >= config.maxRequests) {
    return false;
  }
  
  requests.push(now);
  
  await env.RATELIMIT.put(key, JSON.stringify(requests), {
    expirationTtl: Math.ceil(config.windowMs / 1000),
  });
  
  return true;
}

export function rateLimitMiddleware(action: keyof typeof RATE_LIMITS) {
  return async (c: Context, next: () => Promise<void>) => {
    const allowed = await checkRateLimit(c, action);
    
    if (!allowed) {
      return c.text('Rate limit exceeded. Please try again later.', 429);
    }
    
    await next();
  };
}
