# 🔧 Fix Deployment - Railway Setup

## Current Status:
- ✅ Project created: "CountyWorker System"
- ❌ No service added yet

---

## 🚀 Complete These Steps in Railway Dashboard:

### Step 1: Open Railway Dashboard
```
https://railway.app/dashboard
```

### Step 2: Open Your Project
- Click on "CountyWorker System" project

### Step 3: Add PostgreSQL Database
1. Click **"+ New"** button
2. Select **"Database"**
3. Choose **"Add PostgreSQL"**
4. Wait 30 seconds for it to provision
5. ✅ Database ready!

### Step 4: Add Backend Service
1. Click **"+ New"** button again
2. Select **"GitHub Repo"** OR **"Empty Service"**

**If using Empty Service:**
- Click on the new service
- Go to Settings → Source
- Click "Deploy from CLI"

Then run in terminal:
```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"
railway up
```

**OR If using GitHub Repo:**
- Connect your GitHub account
- Select your repository
- Set root directory to: `backend`
- Railway will auto-deploy

### Step 5: Set Environment Variables
1. Click on your backend service (NOT the database)
2. Go to **"Variables"** tab
3. Click **"+ New Variable"**
4. Add these THREE variables:

```
FLASK_ENV=production
```
```
SECRET_KEY=ef6bec1046cfb824a0336f76643803097d2579a5af5cae4d77dfcf9f7c7df32e
```
```
JWT_SECRET_KEY=df1a921c9ae8b7f833356f174cd2a627c8e673f330537d41ddf4dbb3cef629f4
```

### Step 6: Generate Public Domain
1. Stay in backend service
2. Go to **"Settings"** tab
3. Scroll to **"Networking"**
4. Click **"Generate Domain"**
5. **COPY THE URL** (e.g., `https://countyworker-production-xxxx.up.railway.app`)
6. **SAVE IT!** You'll need this for frontend

### Step 7: Wait for Deployment
1. Go to **"Deployments"** tab
2. Watch the build logs
3. Wait for **"Success"** status (2-3 minutes)

### Step 8: Initialize Database
After deployment succeeds, run:

```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"

railway run flask db init
railway run flask db migrate -m "Initial migration"
railway run flask db upgrade
railway run python3 seed.py
```

### Step 9: Test Backend
```bash
# Replace with YOUR Railway URL
curl https://your-railway-url.railway.app/health
```

**Expected:**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

✅ **If you see this, backend is deployed!**

---

## 🔥 Then Deploy Frontend

### Step 1: Update API URL
Edit: `/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/lib/services/api_service.dart`

Line 7, change to:
```dart
static const String baseUrl = 'https://your-railway-url.railway.app';
```

### Step 2: Build and Deploy
```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"

# Login to Firebase
firebase login

# Initialize (if not done)
firebase init hosting

# Build
flutter clean
flutter pub get
flutter build web --release

# Deploy
firebase deploy --only hosting
```

---

## 🎉 Done!

Your app will be live at:
- **Backend:** https://your-railway-url.railway.app
- **Frontend:** https://your-project.web.app

---

## 📞 If You Need Help:

**Tell me which step you're on and I'll guide you!**

Current step: **Add PostgreSQL Database** (Step 3)
