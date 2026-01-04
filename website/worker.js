export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    let path = url.pathname;

    // Default to index.html for root
    if (path === '/') {
      path = '/index.html';
    }

    // Try to get the asset
    try {
      const asset = await env.ASSETS.fetch(request);
      
      // If the path doesn't have an extension and asset returns 404, try adding .html
      if (asset.status === 404 && !path.includes('.')) {
        const htmlRequest = new Request(url.origin + path + '.html', request);
        const htmlAsset = await env.ASSETS.fetch(htmlRequest);
        if (htmlAsset.status !== 404) {
          return htmlAsset;
        }
      }
      
      return asset;
    } catch (e) {
      // Return 404 page or error
      return new Response('Not Found', { status: 404 });
    }
  },
};
