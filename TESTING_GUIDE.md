# Testing Guide - County Worker Platform

Complete testing guide for the County Government Worker Registration and Assignment Platform.

## 🧪 Testing Checklist

### Backend API Testing

#### 1. Health Check
```bash
curl http://localhost:5000/
curl http://localhost:5000/health
```

Expected Response:
```json
{
  "status": "success",
  "message": "County Worker Platform API",
  "version": "1.0.0",
  "developer": "Kelvin Barasa (DSE-01-8475-2023)"
}
```

#### 2. Authentication Tests

**Signup:**
```bash
curl -X POST http://localhost:5000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Login (Admin):**
```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "hr@county.go.ke",
    "password": "password"
  }'
```

Save the token from response for subsequent requests.

**Get Profile:**
```bash
curl http://localhost:5000/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### 3. Job Endpoints

**Get All Jobs:**
```bash
curl http://localhost:5000/api/jobs
```

**Create Job (Admin only):**
```bash
curl -X POST http://localhost:5000/api/jobs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "title": "Test Job",
    "description": "Test job description",
    "department_id": 1
  }'
```

#### 4. Application Endpoints

**Apply for Job:**
```bash
curl -X POST http://localhost:5000/api/applications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer APPLICANT_TOKEN" \
  -d '{
    "job_id": 1
  }'
```

**Update Application (Admin only):**
```bash
curl -X PUT http://localhost:5000/api/applications/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "status": "accepted"
  }'
```

#### 5. Task Endpoints

**Get Tasks:**
```bash
curl http://localhost:5000/api/tasks \
  -H "Authorization: Bearer WORKER_TOKEN"
```

**Create Task (Supervisor):**
```bash
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SUPERVISOR_TOKEN" \
  -d '{
    "title": "Test Task",
    "description": "Test task description",
    "assigned_to": 4,
    "start_date": "2025-01-15T08:00:00",
    "end_date": "2025-01-22T17:00:00"
  }'
```

**Update Task Progress:**
```bash
curl -X PUT http://localhost:5000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer WORKER_TOKEN" \
  -d '{
    "progress_status": "in_progress"
  }'
```

#### 6. Payment Endpoints

**Get Payments:**
```bash
curl http://localhost:5000/api/payments \
  -H "Authorization: Bearer WORKER_TOKEN"
```

**Update Payment (Admin):**
```bash
curl -X PUT http://localhost:5000/api/payments/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "status": "paid"
  }'
```

---

## 📱 Frontend Testing

### Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | hr@county.go.ke | password |
| Supervisor | sup@county.go.ke | password |
| Worker | worker@county.go.ke | password |
| Applicant | applicant@county.go.ke | password |

### 1. Applicant Flow

1. **Login**
   - Open app
   - Enter: applicant@county.go.ke / password
   - Click "Login"
   - ✅ Should navigate to Applicant Dashboard

2. **View Jobs**
   - ✅ Should see list of open jobs
   - ✅ Each job shows title, department, description
   - ✅ "Apply Now" button visible for jobs not applied to

3. **Apply for Job**
   - Click "Apply Now" on a job
   - Confirm in dialog
   - ✅ Should show success message
   - ✅ Button changes to "Already Applied"

4. **Check Application Status**
   - Switch to "My Applications" tab
   - ✅ Should see submitted application
   - ✅ Status badge shows "PENDING"

5. **Pull to Refresh**
   - Pull down on jobs list
   - ✅ Should reload jobs

### 2. Worker Flow

1. **Login**
   - Enter: worker@county.go.ke / password
   - ✅ Should navigate to Worker Dashboard

2. **View Tasks**
   - ✅ Should see assigned tasks
   - ✅ Each task shows title, description, dates
   - ✅ Status badge shows current progress

3. **Update Task Progress**
   - Click "Update Progress" on a task
   - Select new status (e.g., "In Progress")
   - ✅ Should show success message
   - ✅ Task status updates

4. **View Payments**
   - Switch to "Payments" tab
   - ✅ Should see payment summary cards (Paid/Pending)
   - ✅ Should see list of all payments
   - ✅ Each payment shows amount and status

5. **Pull to Refresh**
   - Pull down on tasks/payments
   - ✅ Should reload data

### 3. Supervisor Flow

1. **Login**
   - Enter: sup@county.go.ke / password
   - ✅ Should navigate to Supervisor Dashboard

2. **View Tasks**
   - ✅ Should see all department tasks
   - ✅ Summary cards show Pending/In Progress/Completed counts
   - ✅ Tasks grouped by status

3. **Assign New Task**
   - Click "Assign Task" FAB
   - Fill in task details:
     - Title: "Test Task"
     - Description: "Test description"
     - Select worker
     - Set start/end dates
   - Click "Assign Task"
   - ✅ Should show success message
   - ✅ New task appears in list

4. **View Task Details**
   - Tap on a task card
   - ✅ Should expand to show full details
   - ✅ Shows worker name, dates, description

### 4. Admin Flow

1. **Login**
   - Enter: hr@county.go.ke / password
   - ✅ Should navigate to Admin Dashboard

2. **View Dashboard**
   - ✅ Should see 4 stat cards:
     - Pending Applications
     - Approved Workers
     - Open Jobs
     - Pending Payments
   - ✅ Should see total unpaid amount
   - ✅ Quick actions section visible

3. **Review Applications**
   - Switch to "Applications" tab
   - ✅ Should see pending applications
   - ✅ Each shows applicant name, email, job title

4. **Approve Application**
   - Click "Accept" on an application
   - ✅ Should show success message
   - ✅ Application removed from pending list

5. **Reject Application**
   - Click "Reject" on an application
   - ✅ Should show success message
   - ✅ Application removed from pending list

6. **Process Payments**
   - Switch to "Payments" tab
   - ✅ Should see unpaid payments
   - ✅ Each shows worker name, amount, task

7. **Mark Payment as Paid**
   - Click "Mark Paid" on a payment
   - ✅ Should show success message
   - ✅ Payment removed from unpaid list

---

## 🔄 Integration Testing

### End-to-End User Journey

#### Journey 1: From Applicant to Worker

1. **Apply for Job (Applicant)**
   - Login as applicant
   - Apply for "Street Cleaning Officer"
   - Verify application status is "Pending"

2. **Approve Application (Admin)**
   - Logout
   - Login as admin
   - Navigate to Applications tab
   - Accept the application
   - Verify success message

3. **Verify Role Change (Worker)**
   - Logout
   - Login with same applicant credentials
   - ✅ Should now see Worker Dashboard (role changed)

#### Journey 2: Task Assignment and Completion

1. **Assign Task (Supervisor)**
   - Login as supervisor
   - Create new task for a worker
   - Set dates and description
   - Assign task

2. **Accept and Start Task (Worker)**
   - Login as worker
   - View assigned task
   - Update status to "In Progress"

3. **Complete Task (Worker)**
   - Update task status to "Completed"
   - Verify completion timestamp

4. **Verify Completion (Supervisor)**
   - Login as supervisor
   - Check task status
   - ✅ Should show "Completed" with completion date

#### Journey 3: Payment Processing

1. **Create Payment (Admin)**
   - Login as admin
   - (This requires backend API call or admin panel)

2. **View Payment (Worker)**
   - Login as worker
   - Navigate to Payments tab
   - ✅ Should see unpaid payment

3. **Process Payment (Admin)**
   - Login as admin
   - Navigate to Payments tab
   - Mark payment as paid

4. **Verify Payment (Worker)**
   - Login as worker
   - Check payments
   - ✅ Should show payment as "Paid"

---

## 🐛 Common Issues and Solutions

### Backend Issues

**Issue:** Port 5000 already in use
```bash
# Find and kill process
lsof -i :5000
kill -9 <PID>
```

**Issue:** Database locked
```bash
# Delete and recreate database
rm backend/county_worker.db
cd backend
python seed.py
```

**Issue:** Import errors
```bash
# Activate virtual environment
source backend/venv/bin/activate
pip install -r backend/requirements.txt
```

### Frontend Issues

**Issue:** Cannot connect to backend
- Check backend is running
- Verify IP address in `api_service.dart`
- Ensure phone/emulator on same network
- Try using IP instead of localhost

**Issue:** Token expired
- Logout and login again
- Clear app data

**Issue:** Build errors
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

---

## ✅ Test Results Template

Use this template to document your testing:

```
Date: ___________
Tester: ___________

BACKEND TESTS
[ ] Health check endpoint
[ ] User signup
[ ] User login (all roles)
[ ] Get profile
[ ] Create job
[ ] Apply for job
[ ] Update application
[ ] Create task
[ ] Update task
[ ] Process payment

FRONTEND TESTS
Applicant:
[ ] Login
[ ] View jobs
[ ] Apply for job
[ ] View applications

Worker:
[ ] Login
[ ] View tasks
[ ] Update task progress
[ ] View payments

Supervisor:
[ ] Login
[ ] View tasks
[ ] Assign task
[ ] View workers

Admin:
[ ] Login
[ ] View dashboard
[ ] Approve application
[ ] Process payment

INTEGRATION TESTS
[ ] Applicant to Worker journey
[ ] Task assignment and completion
[ ] Payment processing flow

ISSUES FOUND:
1. ___________
2. ___________
3. ___________
```

---

## 📊 Performance Testing

### Load Testing (Optional)

Using Apache Bench:
```bash
# Test login endpoint
ab -n 100 -c 10 -p login.json -T application/json http://localhost:5000/auth/login

# Test jobs endpoint
ab -n 100 -c 10 http://localhost:5000/api/jobs
```

### Expected Response Times
- Health check: < 50ms
- Login: < 200ms
- Get jobs: < 300ms
- Create task: < 500ms

---

## 🎯 Acceptance Criteria

### Must Pass
- ✅ All 4 user roles can login
- ✅ Role-based navigation works correctly
- ✅ Applicants can apply for jobs
- ✅ Admin can approve/reject applications
- ✅ Supervisors can assign tasks
- ✅ Workers can update task progress
- ✅ Admin can process payments
- ✅ All API endpoints return correct responses
- ✅ Error handling works (invalid credentials, network errors)
- ✅ Pull-to-refresh works on all screens

### Should Pass
- ✅ Smooth animations and transitions
- ✅ Responsive design on different screen sizes
- ✅ Proper error messages displayed
- ✅ Loading states shown during API calls
- ✅ Data persists after app restart

---

**Testing completed by:** Kelvin Barasa (DSE-01-8475-2023)
