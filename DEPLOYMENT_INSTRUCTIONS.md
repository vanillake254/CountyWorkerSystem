# County Worker Platform - Deployment Instructions

## 🚀 Current Status

### ✅ Completed
1. **Backend Updates** - All pushed to GitHub (auto-deploys to Railway)
2. **Frontend Web App** - Deployed to Firebase Hosting
3. **Database Schema** - Migration script created

### ⚠️ Action Required: Run Database Migration on Railway

## 📋 Database Migration Steps

The Railway PostgreSQL database needs to be updated with new columns. Here's how:

### Option 1: Railway Dashboard (Recommended)

1. Go to Railway Dashboard: https://railway.app
2. Select your `CountyWorkerPlatform` project
3. Click on your backend service
4. Go to the **"Deploy"** tab
5. Click **"Run Command"** or use the Railway CLI
6. Run this command:
   ```bash
   python migrate_db.py
   ```

### Option 2: Railway CLI

```bash
# Install Railway CLI if not installed
npm install -g @railway/cli

# Login to Railway
railway login

# Link to your project
railway link

# Run migration
railway run python migrate_db.py
```

### Option 3: Temporary Endpoint

Add this to your `app.py` temporarily (remove after migration):

```python
@app.route('/migrate-database', methods=['POST'])
def run_migration():
    from migrate_db import migrate_database
    try:
        migrate_database()
        return jsonify({'status': 'success', 'message': 'Migration completed'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500
```

Then call: `POST https://countyworker-system-production.up.railway.app/migrate-database`

## 🗄️ What the Migration Does

The migration adds these columns:

### Users Table
- `salary` (FLOAT) - Monthly salary assigned by admin
- `salary_balance` (FLOAT) - Remaining unpaid salary balance

### Tasks Table  
- `approved_at` (TIMESTAMP) - When supervisor approved/denied task
- `supervisor_comment` (TEXT) - Supervisor's comment on task

### Updates
- Sets initial `salary_balance = salary` for existing workers
- Changes task status from 'pending'/'in_progress' to 'incomplete'/'completed'/'approved'/'denied'

## 🌐 Deployed URLs

### Web Application
**URL:** https://county-worker-platform.web.app

**Test Credentials:**
- Admin: `hr@county.go.ke` / `password`
- Supervisor: `sup@county.go.ke` / `password`
- Worker: `worker@county.go.ke` / `password`
- Applicant: `applicant@county.go.ke` / `password`

### Backend API
**URL:** https://countyworker-system-production.up.railway.app

**Health Check:** https://countyworker-system-production.up.railway.app/health

## 📱 Mobile App (APK)

To build the APK:
```bash
cd frontend
flutter build apk --release
```

APK will be at: `frontend/build/app/outputs/flutter-apk/app-release.apk`

## 🔄 Complete Workflow After Migration

### 1. Job Application Flow
1. Applicant applies for job → Status: **Pending**
2. Admin reviews in Applications tab
3. Admin clicks **Accept** → Dialog appears:
   - Enter monthly salary (e.g., 25000)
   - Select department
   - Click Accept
4. User becomes **Worker** with:
   - Role: worker
   - Salary: 25000
   - Salary Balance: 25000
   - Department assigned

### 2. Task Assignment & Approval Flow
1. Supervisor creates task → Status: **Incomplete**
2. Worker sees task, clicks **Mark as Complete**
3. Task status → **Completed** (waiting for approval)
4. Supervisor sees completed task
5. Supervisor clicks **Approve** or **Deny** (with optional comment)
6. Status → **Approved** or **Denied**
7. Worker sees updated status and supervisor comment (if denied)

### 3. Payment Processing Flow
1. Admin sees approved tasks
2. Admin creates payment or clicks existing payment
3. Admin clicks **Pay** → Dialog shows:
   - Worker name
   - Current salary: 25000
   - Current balance: 25000
   - Payment amount (editable, e.g., 5000)
   - New balance preview: 20000
4. Admin clicks **Process Payment**
5. System:
   - Marks payment as **Paid**
   - Deducts from salary_balance: 25000 - 5000 = 20000
   - Sets paid_at timestamp
6. Worker sees:
   - Payment status: Paid
   - Updated salary balance: 20000

## 🔧 Troubleshooting

### Error: "column users.salary does not exist"
**Solution:** Run the database migration (see steps above)

### Error: "Failed to connect to backend"
**Check:**
1. Railway backend is running
2. API URL in `api_service.dart` is correct
3. CORS is configured for Firebase hosting URL

### Web app loads but shows errors
**Solution:** Clear browser cache and reload

## 📊 System Features

### Admin Dashboard
- ✅ Accept applications with salary assignment
- ✅ Process payments with amount entry
- ✅ View salary balances
- ✅ Manage jobs and departments

### Supervisor Dashboard
- ✅ Assign tasks to workers
- ✅ Approve/deny completed tasks
- ✅ Add comments when denying tasks
- ✅ View task status with color coding

### Worker Dashboard
- ✅ Mark tasks as complete
- ✅ View task approval status
- ✅ See supervisor comments
- ✅ View salary and salary balance
- ✅ Track payment history

### Applicant Dashboard
- ✅ View open jobs
- ✅ Apply for positions
- ✅ Track application status

## 🎯 Next Steps

1. **Run database migration on Railway** (CRITICAL)
2. Test the complete workflow
3. Build and distribute mobile APK
4. Optional: Add more sample data via admin dashboard

## 📞 Support

**Developer:** Kelvin Barasa (DSE-01-8475-2023)
**Project:** County Worker Platform
**Tech Stack:** Flask + Flutter + PostgreSQL + Firebase

---

**Last Updated:** October 12, 2025
**Version:** 2.0 (Complete Workflow Implementation)
