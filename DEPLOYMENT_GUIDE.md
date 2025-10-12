# 🚀 Deployment Guide - County Worker Platform

## 📋 Overview
This guide will help you deploy:
- **Backend** → Railway (with PostgreSQL database)
- **Frontend** → Firebase Hosting

---

## 🔧 Part 1: Deploy Backend to Railway

### Step 1: Prepare Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up/Login with GitHub
3. Click "New Project"

### Step 2: Create PostgreSQL Database
1. In your Railway project, click "+ New"
2. Select "Database" → "PostgreSQL"
3. Railway will automatically create a PostgreSQL database
4. Click on the PostgreSQL service
5. Go to "Variables" tab
6. Copy the `DATABASE_URL` (you'll need this)

### Step 3: Deploy Backend
1. In Railway project, click "+ New"
2. Select "GitHub Repo"
3. Connect your GitHub account
4. Select your repository
5. Choose the `backend` folder as the root directory

**OR Deploy from Local:**
1. Install Railway CLI:
   ```bash
   npm install -g @railway/cli
   ```

2. Login to Railway:
   ```bash
   railway login
   ```

3. Navigate to backend folder:
   ```bash
   cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"
   ```

4. Initialize Railway:
   ```bash
   railway init
   ```

5. Link to your project:
   ```bash
   railway link
   ```

6. Deploy:
   ```bash
   railway up
   ```

### Step 4: Set Environment Variables
In Railway dashboard, go to your backend service → Variables tab:

```
FLASK_ENV=production
SECRET_KEY=<generate-a-strong-random-key>
JWT_SECRET_KEY=<generate-another-strong-random-key>
DATABASE_URL=<automatically-set-by-railway>
PORT=<automatically-set-by-railway>
```

**Generate secure keys:**
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### Step 5: Initialize Database
After deployment, run migrations:

1. In Railway dashboard, click on your backend service
2. Go to "Settings" → "Deploy"
3. Add a "Deploy Command":
   ```bash
   flask db upgrade && gunicorn app:app
   ```

**OR** use Railway CLI:
```bash
railway run flask db init
railway run flask db migrate -m "Initial migration"
railway run flask db upgrade
railway run python3 seed.py
```

### Step 6: Get Your Backend URL
1. In Railway dashboard, click on your backend service
2. Go to "Settings" → "Networking"
3. Click "Generate Domain"
4. Copy the URL (e.g., `https://your-app.railway.app`)

---

## 🔥 Part 2: Deploy Frontend to Firebase

### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Initialize Firebase Project
```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"
firebase init hosting
```

**Configuration:**
- Use an existing project or create new one
- Public directory: `build/web`
- Configure as single-page app: `Yes`
- Set up automatic builds with GitHub: `No` (for now)
- Don't overwrite `build/web/index.html`

### Step 4: Update API Base URL
Before building, update the API URL to point to your Railway backend:

**File:** `/frontend/lib/services/api_service.dart`

```dart
class ApiService {
  // Change this to your Railway backend URL
  static const String baseUrl = 'https://your-app.railway.app';
  // ...
}
```

### Step 5: Build Flutter Web App
```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"
flutter build web --release
```

### Step 6: Deploy to Firebase
```bash
firebase deploy --only hosting
```

### Step 7: Get Your Frontend URL
After deployment, Firebase will provide a URL like:
```
https://your-project-id.web.app
```

---

## 🔄 Part 3: Update CORS Settings

After deploying, update the backend CORS to allow your Firebase domain:

**File:** `/backend/app.py`

```python
# Update CORS to allow your Firebase domain
CORS(app, resources={
    r"/*": {
        "origins": [
            "https://your-project-id.web.app",
            "https://your-project-id.firebaseapp.com",
            "http://localhost:8080"  # For local development
        ]
    }
}, supports_credentials=True)
```

Redeploy backend:
```bash
railway up
```

---

## ✅ Part 4: Verify Deployment

### Test Backend:
```bash
curl https://your-app.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected"
}
```

### Test Frontend:
1. Open `https://your-project-id.web.app`
2. Try to login
3. Check browser console for any errors

---

## 🔐 Part 5: Seed Production Database

After deployment, seed the database with initial data:

```bash
railway run python3 seed.py
```

This will create:
- Default admin user: `hr@county.go.ke` / `password`
- Default supervisor: `sup@county.go.ke` / `password`
- Default worker: `worker@county.go.ke` / `password`
- Default applicant: `applicant@county.go.ke` / `password`
- Sample departments
- Sample jobs

**⚠️ IMPORTANT:** Change these default passwords in production!

---

## 📊 Part 6: Monitor Your Deployment

### Railway Monitoring:
1. Go to Railway dashboard
2. Click on your backend service
3. View "Metrics" tab for:
   - CPU usage
   - Memory usage
   - Request logs
   - Error logs

### Firebase Monitoring:
1. Go to Firebase Console
2. Select your project
3. Go to "Hosting" → "Usage"
4. View traffic and bandwidth

---

## 🔧 Troubleshooting

### Backend Issues:

**Database Connection Error:**
```bash
# Check DATABASE_URL is set correctly
railway variables

# Check database is running
railway run flask db current
```

**Module Not Found:**
```bash
# Ensure all dependencies are in requirements.txt
railway run pip list
```

**Port Binding Error:**
- Railway automatically sets PORT environment variable
- Ensure app.py uses `os.getenv('PORT', 5000)`

### Frontend Issues:

**API Connection Error:**
- Check API base URL in `api_service.dart`
- Verify CORS settings in backend
- Check browser console for errors

**Build Failed:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

**404 on Refresh:**
- Ensure Firebase hosting is configured as SPA
- Check `firebase.json` has proper rewrites

---

## 🔄 Continuous Deployment

### Auto-Deploy Backend (Railway):
1. Connect your GitHub repository to Railway
2. Railway will auto-deploy on every push to main branch

### Auto-Deploy Frontend (Firebase):
1. Set up GitHub Actions:

Create `.github/workflows/firebase-deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main
    paths:
      - 'frontend/**'

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Build
        run: |
          cd frontend
          flutter pub get
          flutter build web --release
      
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-project-id
```

---

## 📝 Environment Variables Summary

### Railway (Backend):
```
FLASK_ENV=production
SECRET_KEY=<your-secret-key>
JWT_SECRET_KEY=<your-jwt-secret-key>
DATABASE_URL=<auto-set-by-railway>
PORT=<auto-set-by-railway>
```

### Firebase (Frontend):
Update in code before building:
- API Base URL in `api_service.dart`

---

## 🎉 Deployment Complete!

Your County Worker Platform is now live:
- **Backend API:** `https://your-app.railway.app`
- **Frontend Web:** `https://your-project-id.web.app`
- **Database:** PostgreSQL on Railway (persistent storage)

### Next Steps:
1. ✅ Change default passwords
2. ✅ Set up custom domain (optional)
3. ✅ Enable SSL (automatic on Railway & Firebase)
4. ✅ Set up monitoring and alerts
5. ✅ Create backup strategy for database

---

## 📞 Support

**Developer:** Kelvin Barasa  
**Email:** vanillasoftwares@gmail.com  
**Website:** https://vanillasoftwares.web.app

---

## 🔒 Security Checklist

- [ ] Changed all default passwords
- [ ] Set strong SECRET_KEY and JWT_SECRET_KEY
- [ ] Configured proper CORS origins
- [ ] Enabled HTTPS (automatic)
- [ ] Set up database backups
- [ ] Reviewed and limited API rate limits
- [ ] Set up error monitoring
- [ ] Configured environment variables properly
- [ ] Removed debug mode in production
- [ ] Set up logging and monitoring

---

**Powered by VANILLA SOFTWARES** 🚀
