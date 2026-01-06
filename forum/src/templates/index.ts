import { Eta } from 'eta';
import { Context } from 'hono';
import { generateCSRFToken } from '../security/csrf';
import { readFileSync } from 'fs';
import { join } from 'path';

// Load templates at startup (for Workers compatibility)
const templates: Record<string, string> = {};

// In Workers, we'll need to inline templates or use a different approach
// For now, this works in Node mode and we can optimize for Workers later
const eta = new Eta({
  autoEscape: true,
  cache: true,
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
    // For Workers, we'll need to bundle templates or use a different approach
    // This is a simplified version that works in Node mode
    const html = eta.renderString(getTemplateContent(template), templateData);
    return c.html(html as string);
  } catch (error) {
    console.error('Template render error:', error);
    return c.text('Template rendering error', 500);
  }
}

// Helper to get template content
// In production, templates should be bundled or loaded differently for Workers
function getTemplateContent(template: string): string {
  // This is a placeholder - in a real Workers deployment, 
  // templates would need to be bundled or served differently
  // For now, returning a simple error message
  return '<html><body><h1>Template System</h1><p>Template rendering is configured for Workers runtime.</p></body></html>';
}

export { eta };
