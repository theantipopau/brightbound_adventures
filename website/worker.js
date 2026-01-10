export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    let path = url.pathname;

    // Default to index.html for root
    if (path === '/') {
      path = '/index.html';
    }

    // Set cache headers based on file type
    const response = await env.ASSETS.fetch(request);
    
    if (response.status === 200) {
      // Determine cache duration based on file type
      let cacheControl = 'public, max-age=3600'; // 1 hour default
      
      if (path.match(/\.(js|css)$/)) {
        // Assets: cache for 30 days
        cacheControl = 'public, max-age=2592000, immutable';
      } else if (path.match(/\.(png|jpg|jpeg|gif|svg|webp|ico)$/)) {
        // Images: cache for 30 days
        cacheControl = 'public, max-age=2592000, immutable';
      } else if (path.match(/\.(html|xml|json|txt|pdf)$/)) {
        // HTML/Documents: cache for 1 hour
        cacheControl = 'public, max-age=3600';
      } else if (path.match(/\.(woff|woff2|ttf|eot)$/)) {
        // Fonts: cache for 1 year
        cacheControl = 'public, max-age=31536000, immutable';
      }

      // Create a new response with cache headers
      const newResponse = new Response(response.body, response);
      newResponse.headers.set('Cache-Control', cacheControl);
      newResponse.headers.set('X-Content-Type-Options', 'nosniff');
      newResponse.headers.set('X-Frame-Options', 'SAMEORIGIN');
      newResponse.headers.set('X-XSS-Protection', '1; mode=block');
      
      return newResponse;
    }
    
    // If the path doesn't have an extension and asset returns 404, try adding .html
    if (response.status === 404 && !path.includes('.')) {
      const htmlRequest = new Request(url.origin + path + '.html', request);
      const htmlAsset = await env.ASSETS.fetch(htmlRequest);
      if (htmlAsset.status !== 404) {
        const newResponse = new Response(htmlAsset.body, htmlAsset);
        newResponse.headers.set('Cache-Control', 'public, max-age=3600');
        return newResponse;
      }
    }
    
    return response;
  },
};
