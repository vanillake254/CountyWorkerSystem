# 🚀 DEPLOY NOW - Step by Step Instructions

## ✅ Prerequisites Installed
- ✅ Railway CLI installed
- ✅ Firebase CLI installed
- ✅ Secret keys generated

---

## 🔐 Your Generated Keys

**SAVE THESE - You'll need them for Railway:**

```
SECRET_KEY=ef6bec1046cfb824a0336f76643803097d2579a5af5cae4d77dfcf9f7c7df32e
JWT_SECRET_KEY=df1a921c9ae8b7f833356f174cd2a627c8e673f330537d41ddf4dbb3cef629f4
```

---

## 🚂 PART 1: Deploy Backend to Railway

### Option A: Using Railway Dashboard (Recommended - Easier)

1. **Open Railway Dashboard**
   ```
   Open browser: https://railway.app
   ```

2. **Login/Signup**
   - Click "Login" or "Start a New Project"
   - Sign in with GitHub

3. **Create New Project**
   - Click "New Project"
   - Select "Empty Project"
   - Name it: "county-worker-backend"

4. **Add PostgreSQL Database**
   - In your project, click "+ New"
   - Select "Database" → "PostgreSQL"
   - Wait for it to provision (30 seconds)

5. **Deploy Backend**
   - Click "+ New" again
   - Select "Empty Service"
   - Click on the new service
   - Go to "Settings" tab
   - Under "Source", click "Connect Repo"
   - OR use "Deploy from local directory" and select:
     `/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend`

6. **Set Environment Variables**
   - Click on your backend service
   - Go to "Variables" tab
   - Click "+ New Variable"
   - Add these one by one:
     ```
     FLASK_ENV=production
     SECRET_KEY=ef6bec1046cfb824a0336f76643803097d2579a5af5cae4d77dfcf9f7c7df32e
     JWT_SECRET_KEY=df1a921c9ae8b7f833356f174cd2a627c8e673f330537d41ddf4dbb3cef629f4
     ```
   - DATABASE_URL and PORT are automatically set by Railway

7. **Generate Public Domain**
   - Go to "Settings" tab
   - Scroll to "Networking"
   - Click "Generate Domain"
   - **COPY THIS URL** (e.g., `https://county-worker-backend-production.up.railway.app`)
   - Save it - you'll need it for frontend!

8. **Wait for Deployment**
   - Go to "Deployments" tab
   - Wait for status to show "Success" (2-3 minutes)

9. **Initialize Database**
   Open terminal and run:
   ```bash
   cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"
   railway login
   railway link
   # Select your project: county-worker-backend
   railway run flask db init
   railway run flask db migrate -m "Initial migration"
   railway run flask db upgrade
   railway run python3 seed.py
   ```

10. **Test Backend**
    ```bash
    curl https://your-railway-url.railway.app/health
    ```
    Should return: `{"status": "healthy", "database": "connected"}`

### Option B: Using CLI (Advanced)

```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"

# Login
railway login

# Create new project
railway init

# Add PostgreSQL
railway add

# Deploy
railway up

# Set variables
railway variables set FLASK_ENV=production
railway variables set SECRET_KEY=ef6bec1046cfb824a0336f76643803097d2579a5af5cae4d77dfcf9f7c7df32e
railway variables set JWT_SECRET_KEY=df1a921c9ae8b7f833356f174cd2a627c8e673f330537d41ddf4dbb3cef629f4

# Initialize database
railway run flask db init
railway run flask db migrate -m "Initial"
railway run flask db upgrade
railway run python3 seed.py
```

---

## 🔥 PART 2: Deploy Frontend to Firebase

### Step 1: Update API URL

**IMPORTANT:** Replace with your Railway backend URL!

Edit this file:
```
/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend/lib/services/api_service.dart
```

Change line 7:
```dart
// FROM:
static const String baseUrl = 'http://localhost:5000';

// TO:
static const String baseUrl = 'https://your-railway-url.railway.app';
```

### Step 2: Login to Firebase

```bash
firebase login
```

This will open a browser for authentication.

### Step 3: Create Firebase Project

**Option A: Using Firebase Console (Easier)**
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Project name: `county-worker-platform`
4. Disable Google Analytics (optional)
5. Click "Create project"
6. Wait for project creation

**Option B: Using CLI**
```bash
firebase projects:create county-worker-platform
```

### Step 4: Initialize Firebase in Your Project

```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"

firebase init hosting
```

**Answer the prompts:**
- Use an existing project: **Yes**
- Select: **county-worker-platform**
- Public directory: **build/web**
- Configure as single-page app: **Yes**
- Set up automatic builds: **No**
- File build/web/index.html already exists. Overwrite: **No**

### Step 5: Build Flutter Web App

```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"

flutter clean
flutter pub get
flutter build web --release
```

Wait for build to complete (2-3 minutes).

### Step 6: Deploy to Firebase

```bash
firebase deploy --only hosting
```

Wait for deployment (1-2 minutes).

### Step 7: Get Your Frontend URL

After deployment, Firebase will show:
```
✔  Deploy complete!

Hosting URL: https://county-worker-platform.web.app
```

**SAVE THIS URL!**

---

## 🔄 PART 3: Update CORS Settings

Now that you have your Firebase URL, update backend CORS:

Edit:
```
/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend/app.py
```

Find line 26 and update:
```python
# FROM:
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

# TO:
CORS(app, resources={
    r"/*": {
        "origins": [
            "https://county-worker-platform.web.app",
            "https://county-worker-platform.firebaseapp.com",
            "http://localhost:8080"
        ]
    }
}, supports_credentials=True)
```

**Redeploy backend:**
```bash
cd backend
railway up
```

---

## ✅ PART 4: Test Your Deployment

### Test Backend:
```bash
curl https://your-railway-url.railway.app/health
```

Expected:
```json
{
  "status": "healthy",
  "database": "connected"
}
```

### Test Frontend:
1. Open: `https://county-worker-platform.web.app`
2. Should see login screen
3. Login with:
   - Email: `hr@county.go.ke`
   - Password: `password`
4. Should successfully login to admin dashboard

### Check Browser Console:
- Press F12
- Go to Console tab
- Should see no errors
- Should see: `🔐 Attempting login for: hr@county.go.ke`

---

## 🎉 Deployment Complete!

Your URLs:
- **Backend:** `https://your-railway-url.railway.app`
- **Frontend:** `https://county-worker-platform.web.app`
- **Database:** PostgreSQL on Railway

### Default Test Credentials:
| Role | Email | Password |
|------|-------|----------|
| Admin | hr@county.go.ke | password |
| Supervisor | sup@county.go.ke | password |
| Worker | worker@county.go.ke | password |
| Applicant | applicant@county.go.ke | password |

**⚠️ IMPORTANT:** Change these passwords after first login!

---

## 🆘 Troubleshooting

### Backend deployment failed:
```bash
railway logs
```

### Frontend can't reach backend:
- Check API URL in `api_service.dart`
- Check CORS settings in `app.py`
- Check browser console for errors

### Database not initialized:
```bash
railway run flask db upgrade
railway run python3 seed.py
```

---

## 📞 Need Help?

**Developer:** Kelvin Barasa  
**Email:** vanillasoftwares@gmail.com

---

## 🚀 Quick Commands Reference

### Backend (Railway):
```bash
railway login          # Login to Railway
railway link          # Link to project
railway up            # Deploy
railway logs          # View logs
railway run <cmd>     # Run command
railway variables     # View env vars
```

### Frontend (Firebase):
```bash
firebase login                    # Login
firebase init hosting            # Initialize
flutter build web --release      # Build
firebase deploy --only hosting   # Deploy
firebase hosting:channel:list    # List deployments
```

---

**Powered by VANILLA SOFTWARES** 🚀
