# Quick Start Guide - County Worker Platform

Get the County Government Worker Registration and Assignment Platform running in 5 minutes!

## 🚀 Prerequisites

- Python 3.8+ installed
- Flutter 3.0+ installed
- Terminal/Command Prompt access

## 📦 Step 1: Backend Setup (2 minutes)

### Open Terminal 1

```bash
# Navigate to project
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/backend"

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# OR
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Seed database with sample data
python seed.py

# Start backend server
python app.py
```

✅ **Backend running at:** `http://localhost:5000`

Keep this terminal open!

## 📱 Step 2: Frontend Setup (2 minutes)

### Open Terminal 2

```bash
# Navigate to frontend
cd "/home/vanilla-ke/development/SCHOOL PROJECT/CountyWorkerPlatform/frontend"

# Install dependencies
flutter pub get

# IMPORTANT: Update API URL
# Edit lib/services/api_service.dart
# Change baseUrl to your IP address
```

### Find Your IP Address

**Linux/Mac:**
```bash
ifconfig | grep "inet "
# Look for something like: 192.168.1.100
```

**Windows:**
```bash
ipconfig
# Look for IPv4 Address
```

### Update API Service

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:5000';
// Example: 'http://192.168.1.100:5000'
```

### Run the App

**For Web:**
```bash
flutter run -d chrome
```

**For Android:**
```bash
flutter run
```

**For iOS:**
```bash
flutter run -d ios
```

## 🔑 Step 3: Login and Test (1 minute)

### Test Credentials

| Role | Email | Password |
|------|-------|----------|
| **Admin** | hr@county.go.ke | password |
| **Supervisor** | sup@county.go.ke | password |
| **Worker** | worker@county.go.ke | password |
| **Applicant** | applicant@county.go.ke | password |

### Quick Test Flow

1. **Login as Applicant**
   - Email: `applicant@county.go.ke`
   - Password: `password`
   - ✅ Should see job listings

2. **Apply for a Job**
   - Click "Apply Now" on any job
   - ✅ Should see success message

3. **Login as Admin**
   - Logout
   - Email: `hr@county.go.ke`
   - Password: `password`
   - ✅ Should see admin dashboard

4. **Approve Application**
   - Go to "Applications" tab
   - Click "Accept" on pending application
   - ✅ Application approved!

## 🎯 What You Should See

### Backend Terminal
```
 * Running on http://0.0.0.0:5000
 * Debug mode: on
```

### Frontend
- **Applicant Dashboard**: Job listings with apply buttons
- **Worker Dashboard**: Tasks and payments
- **Supervisor Dashboard**: Task management
- **Admin Dashboard**: System overview with statistics

## 🐛 Troubleshooting

### Backend Not Starting?

```bash
# Check if port 5000 is in use
lsof -i :5000

# Kill the process if needed
kill -9 <PID>

# Try again
python app.py
```

### Frontend Can't Connect?

1. **Check backend is running** (Terminal 1 should show Flask running)
2. **Verify IP address** in `api_service.dart`
3. **Ensure same network** (phone and computer on same WiFi)
4. **Try localhost** if testing on web:
   ```dart
   static const String baseUrl = 'http://localhost:5000';
   ```

### Database Issues?

```bash
# Delete and recreate database
cd backend
rm county_worker.db
python seed.py
```

### Flutter Build Errors?

```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

## 📊 Sample Data Included

After running `seed.py`, you have:

- **5 Departments**
  - Sanitation
  - Water & Infrastructure
  - Administration
  - Health Services
  - Public Works

- **7 Users**
  - 1 Admin
  - 2 Supervisors
  - 2 Workers
  - 2 Applicants

- **4 Jobs**
  - Street Cleaning Officer (Open)
  - Water Pipeline Maintenance Assistant (Open)
  - Data Entry Clerk (Open)
  - Waste Collection Driver (Closed)

- **3 Applications** (Pending, Accepted, Rejected)
- **3 Tasks** (Pending, In Progress, Completed)
- **2 Contracts**
- **3 Payments** (Paid and Unpaid)

## 🎓 Next Steps

1. **Explore All Roles**
   - Try logging in with each role
   - See different dashboards and features

2. **Test Workflows**
   - Apply for jobs as applicant
   - Assign tasks as supervisor
   - Update task progress as worker
   - Process payments as admin

3. **Read Documentation**
   - Main README.md for full documentation
   - TESTING_GUIDE.md for comprehensive testing
   - Backend README.md for API details
   - Frontend README.md for UI customization

4. **Build for Production**
   ```bash
   # Android APK
   cd frontend
   flutter build apk --release
   
   # APK location: build/app/outputs/flutter-apk/app-release.apk
   ```

## 📞 Need Help?

- Check TESTING_GUIDE.md for detailed testing instructions
- Review README.md for architecture and features
- Contact: Kelvin Barasa (DSE-01-8475-2023)

## ✅ Success Checklist

- [ ] Backend running on port 5000
- [ ] Frontend running (web/mobile)
- [ ] Can login with test credentials
- [ ] Can see role-specific dashboards
- [ ] Can perform basic operations (apply, assign, update)

---

**🎉 Congratulations! Your County Worker Platform is running!**

**Developer:** Kelvin Barasa (DSE-01-8475-2023)
