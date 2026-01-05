# Deploying BrightBound Adventures to Cloudflare Pages

## Overview
This guide will help you deploy the Flutter web app to Cloudflare Pages as a separate project named "brightbound" accessible at `playbrightbound.matthurley.dev`.

## Prerequisites
- GitHub repository: `theantipopau/brightbound_adventures`
- Cloudflare account
- Domain: `matthurley.dev` (already in Cloudflare)

## Step 1: Prepare the Build

The Flutter web build is already compiled and ready in the `build/web` directory.

To rebuild if needed:
```bash
flutter build web --release
```

## Step 2: Create Cloudflare Pages Project

1. **Go to Cloudflare Dashboard**
   - Navigate to: https://dash.cloudflare.com
   - Select your account
   - Go to "Workers & Pages" → "Create application" → "Pages" → "Connect to Git"

2. **Connect to GitHub Repository**
   - Select `theantipopau/brightbound_adventures`
   - Click "Begin setup"

3. **Configure Build Settings**
   - **Project name**: `brightbound`
   - **Production branch**: `main`
   - **Build command**: `flutter build web --release`
   - **Build output directory**: `build/web`
   - **Root directory**: `/` (leave empty)

4. **Environment Variables** (if needed)
   - No environment variables required for this project

5. **Advanced Settings**
   - **Node.js version**: Not required (Flutter builds don't need Node)
   - You can skip this section

## Step 3: Initial Deployment

1. Click "Save and Deploy"
2. Cloudflare will:
   - Clone your repository
   - Run the build command
   - Deploy the contents of `build/web`
   - Assign a temporary URL like `brightbound.pages.dev`

## Step 4: Configure Custom Domain

1. **After deployment completes**, go to the project settings
2. Navigate to "Custom domains" tab
3. Click "Set up a custom domain"
4. Enter: `playbrightbound.matthurley.dev`
5. Cloudflare will:
   - Automatically create the CNAME record in your DNS
   - Provision an SSL certificate
   - Enable HTTPS

## Step 5: Verify DNS Configuration

The DNS should be auto-configured, but verify:

```
Type: CNAME
Name: playbrightbound
Target: brightbound.pages.dev
Proxied: Yes (orange cloud)
```

## Step 6: Configure Build Optimization (Optional)

### Add `_headers` file to the build
Create `web/_headers` with:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()

/flutter_service_worker.js
  Cache-Control: public, max-age=0, must-revalidate

/main.dart.js
  Cache-Control: public, max-age=31536000, immutable

/assets/*
  Cache-Control: public, max-age=31536000, immutable
```

### Add `_redirects` file (if needed)
Create `web/_redirects` with:

```
# SPA fallback
/*    /index.html   200
```

## Step 7: Automatic Deployments

Now configured! Every time you:
1. Push to the `main` branch
2. Cloudflare Pages will automatically:
   - Pull the latest code
   - Run `flutter build web --release`
   - Deploy the new version
   - Update `playbrightbound.matthurley.dev`

## Step 8: Preview Deployments

- Every pull request gets a preview URL
- Preview URLs look like: `abc123.brightbound.pages.dev`
- Perfect for testing before merging!

## Alternative: Manual Deployment via Wrangler CLI

If you prefer CLI deployment:

```bash
# Install Wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Deploy
wrangler pages deploy build/web --project-name=brightbound
```

## Monitoring and Analytics

1. Go to Cloudflare Pages dashboard
2. View analytics:
   - Page views
   - Unique visitors
   - Bandwidth usage
   - Build history

## Rollback if Needed

1. Go to "Deployments" tab
2. Find the previous working deployment
3. Click "..." → "Rollback to this deployment"

## Performance Optimization

Cloudflare Pages automatically provides:
- ✅ Global CDN distribution
- ✅ HTTP/2 and HTTP/3
- ✅ Brotli compression
- ✅ Smart caching
- ✅ DDoS protection
- ✅ Free SSL certificate

## Troubleshooting

### Build fails
- Check Flutter is installed in the build environment
- Verify `build/web` directory exists after build
- Check build logs in Cloudflare dashboard

### Assets not loading
- Verify `<base href="/">` in `web/index.html`
- Check that all assets are in the `build/web` directory

### Custom domain not working
- Wait 5-10 minutes for DNS propagation
- Clear browser cache
- Verify CNAME record points to `brightbound.pages.dev`

## Current Website vs App

- **Website**: `website/` folder (marketing site)
- **Flutter App**: `build/web/` folder (actual game)
- **Deployment**: Flutter app to Cloudflare Pages
- **Marketing site**: Can stay on Cloudflare Workers or separate deployment

## Cost

- **Cloudflare Pages**: FREE
  - Unlimited bandwidth
  - Unlimited requests
  - 500 builds/month
  - 20,000 files per deployment

Perfect for this project! 🚀

## URLs After Deployment

- **Production**: https://playbrightbound.matthurley.dev
- **Cloudflare default**: https://brightbound.pages.dev
- **Preview deployments**: https://[commit-hash].brightbound.pages.dev

## Next Steps

1. Push this guide to your repository
2. Go to Cloudflare Dashboard
3. Create the Pages project
4. Configure the custom domain
5. Start playing! 🎮
