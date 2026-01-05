import { Eta } from 'eta';
import { Context } from 'hono';
import { generateCSRFToken } from '../security/csrf';

const eta = new Eta({
  views: './src/templates',
  cache: false, // Disable cache in development
  autoEscape: true,
});

export async function render(c: Context, template: string, data: any = {}): Promise<Response> {
  const user = c.get('user');
  const session = c.get('session');
  
  // Generate CSRF token for forms
  const csrfToken = await generateCSRFToken(c);
  
  // Merge with global data
  const templateData = {
    ...data,
    user,
    session,
    csrfToken,
    siteName: 'BrightBound Adventures Forum',
    year: new Date().getFullYear(),
  };
  
  try {
    const html = eta.render(template, templateData);
    return c.html(html as string);
  } catch (error) {
    console.error('Template render error:', error);
    return c.text('Template rendering error', 500);
  }
}

export { eta };
