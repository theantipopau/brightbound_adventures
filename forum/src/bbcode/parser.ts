// Safe BBCode parser with whitelist approach

interface BBCodeTag {
  pattern: RegExp;
  replacement: (match: string, ...args: any[]) => string;
}

// Escape HTML to prevent XSS
function escapeHtml(text: string): string {
  const map: Record<string, string> = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  };
  return text.replace(/[&<>"']/g, m => map[m]);
}

// URL validation
function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

// BBCode tags with safe replacements
const bbcodeTags: BBCodeTag[] = [
  // [b]text[/b] -> <strong>text</strong>
  {
    pattern: /\[b\](.*?)\[\/b\]/gi,
    replacement: (match, content) => `<strong>${content}</strong>`,
  },
  // [i]text[/i] -> <em>text</em>
  {
    pattern: /\[i\](.*?)\[\/i\]/gi,
    replacement: (match, content) => `<em>${content}</em>`,
  },
  // [u]text[/u] -> <u>text</u>
  {
    pattern: /\[u\](.*?)\[\/u\]/gi,
    replacement: (match, content) => `<u>${content}</u>`,
  },
  // [url]http://example.com[/url] -> <a href="...">...</a>
  {
    pattern: /\[url\](.*?)\[\/url\]/gi,
    replacement: (match, url) => {
      const trimmed = url.trim();
      if (isValidUrl(trimmed)) {
        return `<a href="${escapeHtml(trimmed)}" target="_blank" rel="noopener noreferrer">${escapeHtml(trimmed)}</a>`;
      }
      return escapeHtml(match);
    },
  },
  // [url=http://example.com]text[/url] -> <a href="...">text</a>
  {
    pattern: /\[url=(.*?)\](.*?)\[\/url\]/gi,
    replacement: (match, url, text) => {
      const trimmed = url.trim();
      if (isValidUrl(trimmed)) {
        return `<a href="${escapeHtml(trimmed)}" target="_blank" rel="noopener noreferrer">${text}</a>`;
      }
      return escapeHtml(match);
    },
  },
  // [quote]text[/quote] -> <blockquote>text</blockquote>
  {
    pattern: /\[quote\](.*?)\[\/quote\]/gis,
    replacement: (match, content) => `<blockquote class="bbcode-quote">${content}</blockquote>`,
  },
  // [quote=author]text[/quote] -> <blockquote><cite>author wrote:</cite>text</blockquote>
  {
    pattern: /\[quote=(.*?)\](.*?)\[\/quote\]/gis,
    replacement: (match, author, content) => 
      `<blockquote class="bbcode-quote"><cite>${escapeHtml(author)} wrote:</cite>${content}</blockquote>`,
  },
  // [code]text[/code] -> <pre><code>text</code></pre>
  {
    pattern: /\[code\](.*?)\[\/code\]/gis,
    replacement: (match, content) => `<pre class="bbcode-code"><code>${escapeHtml(content)}</code></pre>`,
  },
];

export function parseBBCode(text: string): string {
  if (!text) return '';
  
  // First, escape all HTML
  let html = escapeHtml(text);
  
  // Apply BBCode transformations
  for (const tag of bbcodeTags) {
    html = html.replace(tag.pattern, tag.replacement);
  }
  
  // Convert newlines to <br>
  html = html.replace(/\n/g, '<br>');
  
  return html;
}

// Strip all BBCode and return plain text
export function stripBBCode(text: string): string {
  if (!text) return '';
  
  let plain = text;
  
  // Remove all BBCode tags
  plain = plain.replace(/\[\/?\w+(?:=[^\]]+)?\]/gi, '');
  
  return plain;
}

// Validate BBCode syntax (check for unclosed tags)
export function validateBBCode(text: string): { valid: boolean; error?: string } {
  const tags = ['b', 'i', 'u', 'url', 'quote', 'code'];
  const stack: string[] = [];
  
  const regex = /\[(\/?)(b|i|u|url|quote|code)(?:=[^\]]+)?\]/gi;
  let match;
  
  while ((match = regex.exec(text)) !== null) {
    const isClosing = match[1] === '/';
    const tagName = match[2].toLowerCase();
    
    if (isClosing) {
      if (stack.length === 0 || stack[stack.length - 1] !== tagName) {
        return { valid: false, error: `Mismatched closing tag [/${tagName}]` };
      }
      stack.pop();
    } else {
      stack.push(tagName);
    }
  }
  
  if (stack.length > 0) {
    return { valid: false, error: `Unclosed tags: ${stack.join(', ')}` };
  }
  
  return { valid: true };
}
