# ⚡ Quick Deployment Guide

## 🎯 Deploy in 10 Minutes!

### Prerequisites
- GitHub account
- Railway account (free tier available)
- Firebase account (free tier available)

---

## 🚀 Step 1: Deploy Backend to Railway (5 minutes)

### Option A: Using Railway Dashboard (Recommended)

1. **Go to [railway.app](https://railway.app)** and login

2. **Create New Project**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Connect your GitHub account
   - Select your repository
   - Choose `backend` folder as root

3. **Add PostgreSQL Database**
   - In the same project, click "+ New"
   - Select "Database" → "PostgreSQL"
   - Railway automatically links it to your backend

4. **Set Environment Variables**
   - Click on your backend service
   - Go to "Variables" tab
   - Add these variables:
     ```
     FLASK_ENV=production
     SECRET_KEY=<run: python3 -c "import secrets; print(secrets.token_hex(32))">
     JWT_SECRET_KEY=<run: python3 -c "import secrets; print(secrets.token_hex(32))">
     ```

5. **Deploy**
   - Railway will automatically deploy
   - Wait for deployment to complete (2-3 minutes)
   - Click "Settings" → "Networking" → "Generate Domain"
   - **Copy your backend URL** (e.g., `https://your-app.railway.app`)

6. **Initialize Database**
   - Install Railway CLI: `npm install -g @railway/cli`
   - Login: `railway login`
   - Link project: `railway link` (select your project)
   - Run migrations:
     ```bash
     cd backend
     railway run flask db init
     railway run flask db migrate -m "Initial"
     railway run flask db upgrade
     railway run python3 seed.py
     ```

### Option B: Using CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Navigate to backend
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"

# Run deployment script
./deploy-railway.sh
```

---

## 🔥 Step 2: Deploy Frontend to Firebase (5 minutes)

### 1. **Update API URL**

Edit `/frontend/lib/services/api_service.dart`:

```dart
class ApiService {
  // Replace with your Railway backend URL
  static const String baseUrl = 'https://your-app.railway.app';
  // ...
}
```

### 2. **Install Firebase CLI**

```bash
npm install -g firebase-tools
```

### 3. **Login to Firebase**

```bash
firebase login
```

### 4. **Create Firebase Project**

- Go to [console.firebase.google.com](https://console.firebase.google.com)
- Click "Add project"
- Enter project name: `county-worker-platform`
- Disable Google Analytics (optional)
- Click "Create project"

### 5. **Initialize Firebase**

```bash
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"
firebase init hosting
```

**Configuration:**
- Select "Use an existing project"
- Choose `county-worker-platform`
- Public directory: `build/web`
- Single-page app: `Yes`
- Automatic builds: `No`
- Don't overwrite index.html: `No`

### 6. **Build and Deploy**

```bash
# Build Flutter web app
flutter clean
flutter pub get
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**OR use the script:**

```bash
./deploy-firebase.sh
```

### 7. **Get Your URL**

After deployment, Firebase will show:
```
✔  Deploy complete!

Hosting URL: https://county-worker-platform.web.app
```

**Copy this URL!**

---

## 🔄 Step 3: Update CORS (2 minutes)

Edit `/backend/app.py`:

```python
# Update CORS origins
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

## ✅ Step 4: Test Your Deployment

### Test Backend:

```bash
curl https://your-app.railway.app/health
```

Expected:
```json
{
  "status": "healthy",
  "database": "connected"
}
```

### Test Frontend:

1. Open `https://county-worker-platform.web.app`
2. Login with default credentials:
   - Admin: `hr@county.go.ke` / `password`
   - Supervisor: `sup@county.go.ke` / `password`
   - Worker: `worker@county.go.ke` / `password`
   - Applicant: `applicant@county.go.ke` / `password`

3. ✅ If login works, deployment is successful!

---

## 🎉 You're Live!

Your County Worker Platform is now deployed:

- **Backend API:** `https://your-app.railway.app`
- **Frontend Web:** `https://county-worker-platform.web.app`
- **Database:** PostgreSQL on Railway (persistent)

---

## 🔐 Important: Change Default Passwords!

After deployment, immediately change default passwords:

1. Login as admin
2. Go to Users tab
3. Update passwords for all default users

---

## 📊 Monitor Your App

### Railway (Backend):
- Dashboard: https://railway.app/dashboard
- View logs, metrics, and database

### Firebase (Frontend):
- Console: https://console.firebase.google.com
- View hosting usage and analytics

---

## 🆘 Troubleshooting

### Backend not connecting to database:
```bash
railway variables  # Check DATABASE_URL is set
railway logs       # Check for errors
```

### Frontend can't reach backend:
- Check API URL in `api_service.dart`
- Check CORS settings in backend
- Check browser console for errors

### Build failed:
```bash
flutter clean
flutter pub get
flutter build web --release
```

---

## 🔄 Redeploy After Changes

### Backend:
```bash
cd backend
railway up
```

### Frontend:
```bash
cd frontend
flutter build web --release
firebase deploy --only hosting
```

---

## 📞 Need Help?

**Developer:** Kelvin Barasa  
**Email:** vanillasoftwares@gmail.com  
**Website:** https://vanillasoftwares.web.app

---

**Powered by VANILLA SOFTWARES** 🚀
