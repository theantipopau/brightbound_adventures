import { Hono } from 'hono';
import { authMiddleware } from './middleware/auth';
import { AppContext } from './types';
import indexRoutes from './routes/index';
import authRoutes from './routes/auth';
import forumRoutes from './routes/forum';
import threadRoutes from './routes/thread';
import userRoutes from './routes/user';
import messageRoutes from './routes/messages';
import adminRoutes from './routes/admin';

const app = new Hono<AppContext>();

// Security headers
app.use('*', async (c, next) => {
  await next();
  c.header('X-Content-Type-Options', 'nosniff');
  c.header('X-Frame-Options', 'DENY');
  c.header('X-XSS-Protection', '1; mode=block');
  c.header('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // CSP in production
  if (c.env.DEPLOY_TARGET === 'cloudflare') {
    c.header('Content-Security-Policy', 
      "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self'; img-src 'self' data:; font-src 'self'; connect-src 'self';"
    );
  }
});

// Auth middleware - adds user to context
app.use('*', authMiddleware);

// Routes
app.route('/', indexRoutes);
app.route('/', authRoutes);
app.route('/forum', forumRoutes);
app.route('/thread', threadRoutes);
app.route('/user', userRoutes);
app.route('/messages', messageRoutes);
app.route('/admin', adminRoutes);

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }));

// 404 handler
app.notFound((c) => {
  return c.text('Not Found', 404);
});

// Error handler
app.onError((err, c) => {
  console.error('Error:', err);
  return c.text('Internal Server Error', 500);
});

export default app;
