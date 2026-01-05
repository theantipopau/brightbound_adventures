# Deploying BrightBound Adventures to Cloudflare

## Overview
This project has two separate Cloudflare Pages deployments:

1. **Marketing Website** (`/website/` folder)
   - Domain: `brightbound.matthurley.dev`
   - Deployed via: Wrangler CLI
   - Project: Static marketing site

2. **Flutter Game App** (`/build/web/` folder)
   - Domain: `playbrightbound.matthurley.dev`
   - Deployed via: Wrangler CLI or GitHub
   - Project: The actual playable game

---

## Deployment 1: Marketing Website

The marketing website in the `/website/` folder.

### Deploy via Wrangler

```bash
# Navigate to the website folder
cd website

# Deploy to production
wrangler pages deploy . --project-name=brightbound

# Or if already configured
wrangler deploy
```

### Configure Custom Domain

After first deployment:
1. Go to Cloudflare Pages dashboard
2. Select the `brightbound` project
3. Go to "Custom domains"
4. Add: `brightbound.matthurley.dev`

---

## Deployment 2: Flutter Game App

### Option A: Deploy via Wrangler CLI (Recommended - Fastest!)

```bash
# Build the Flutter app first
flutter build web --release

# Deploy directly to Cloudflare Pages
wrangler pages deploy build/web --project-name=playbrightbound

# On first run, it will:
# - Create the "playbrightbound" project
# - Deploy the app
# - Give you a URL like playbrightbound.pages.dev
```

### Configure Custom Domain

After first deployment:
1. Go to Cloudflare Pages dashboard
2. Select the `playbrightbound` project
3. Go to "Custom domains"
4. Add: `playbrightbound.matthurley.dev`

### Option B: Deploy via GitHub (Automatic)

If you prefer automatic deployments on git push:

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

- **Marketing Website** (`website/` folder): Deployed via Wrangler to `brightbound.matthurley.dev` (or custom domain)
  - Static marketing pages (Home, About, Features, FAQ)
  - Deployed with: `cd website && wrangler deploy`
  
- **Flutter App** (`build/web/` folder): Deployed to Cloudflare Pages at `playbrightbound.matthurley.dev`
  - The actual game/app
  - Auto-deploys from GitHub on push to `main`

## Cost

Both Cloudflare Pages deployments are **FREE**:

- Unlimited bandwidth
- Unlimited requests  
- 500 builds/month per project
- 20,000 files per deployment

Perfect for this project! 🚀

## Quick Deploy Commands

### Deploy Marketing Website
```bash
cd website
wrangler pages deploy . --project-name=brightbound
```

### Deploy Flutter Game
```bash
flutter build web --release
wrangler pages deploy build/web --project-name=playbrightbound
```

### Deploy Both
```bash
# Deploy website
cd website
wrangler pages deploy . --project-name=brightbound

# Deploy Flutter app
cd ..
flutter build web --release
wrangler pages deploy build/web --project-name=playbrightbound
```

---

## Prerequisites

- Cloudflare account
- Wrangler CLI installed: `npm install -g wrangler`
- Authenticated: `wrangler login`

---

## Current Website vs App

- **Marketing Website** (`/website/` folder)
  - Cloudflare Pages project: `brightbound`
  - Domain: `brightbound.matthurley.dev`
  - Deploy: `cd website && wrangler pages deploy . --project-name=brightbound`
  
- **Flutter Game** (`/build/web/` folder)
  - Cloudflare Pages project: `playbrightbound`
  - Domain: `playbrightbound.matthurley.dev`
  - Deploy: `flutter build web --release && wrangler pages deploy build/web --project-name=playbrightbound`

## URLs After Deployment

- **Marketing Website**: https://brightbound.matthurley.dev
  - Cloudflare default: https://brightbound.pages.dev
  
- **Flutter Game**: https://playbrightbound.matthurley.dev
  - Cloudflare default: https://playbrightbound.pages.dev

---

## Next Steps - Quickstart! 🚀

### 1. Deploy Marketing Website (30 seconds)
```bash
cd website
wrangler pages deploy . --project-name=brightbound
```

Then add custom domain `brightbound.matthurley.dev` in Cloudflare dashboard.

### 2. Deploy Flutter Game (2 minutes)
```bash
flutter build web --release
wrangler pages deploy build/web --project-name=playbrightbound
```

Then add custom domain `playbrightbound.matthurley.dev` in Cloudflare dashboard.

### 3. Done! ✅

Both sites are now live and will have Cloudflare's global CDN, SSL, and all the benefits!
