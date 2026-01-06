// Template loader for Node.js environment
// This file loads .eta templates from the filesystem
import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { templates } from './index';

export function loadTemplates() {
  const templateDir = join(process.cwd(), 'src', 'templates');
  
  try {
    const files = readdirSync(templateDir);
    
    for (const file of files) {
      if (file.endsWith('.eta')) {
        const content = readFileSync(join(templateDir, file), 'utf-8');
        templates['./' + file] = content;
      }
    }
    
    console.log(`✅ Loaded ${Object.keys(templates).length} templates`);
  } catch (error) {
    console.error('Error loading templates:', error);
  }
}
