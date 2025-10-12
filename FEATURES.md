# County Worker Platform - Complete Features

## 🎯 Overview
A comprehensive multi-role platform for managing county job recruitment, worker assignment, task management, and payroll processing.

## 👥 User Roles

### 1. **Applicant**
- View all open job positions
- Apply for available jobs
- Track application status (Pending/Accepted/Rejected)
- View job details and department information

### 2. **Worker**
- View assigned tasks with progress tracking
- Update task progress (Pending → In Progress → Completed)
- View payment history and pending payments
- **NEW:** Browse and apply for additional job opportunities
- View task deadlines and descriptions

### 3. **Supervisor**
- View all tasks in their department
- Assign new tasks to workers in their department
- Monitor task progress and completion
- View department workers list
- Set task deadlines and priorities

### 4. **Admin/HR**
- **Dashboard Overview:**
  - Pending applications count
  - Approved workers count
  - Open jobs count
  - Pending payments count
  - Total unpaid amount

- **Application Management:**
  - Review pending applications
  - Accept or reject applications
  - Auto-assign workers to departments on acceptance

- **Payment Processing:**
  - View all pending payments
  - Mark payments as paid
  - Track payment history

- **Job Management (NEW):**
  - Create new job positions
  - Edit existing jobs (title, description, status)
  - Assign jobs to departments
  - Open/Close job positions
  - Delete jobs (cascades to applications)

- **Department Management (NEW):**
  - Create new departments
  - Assign supervisors to departments
  - Edit department details
  - Delete departments
  - View department structure

## 🔧 Technical Features

### Backend (Flask + SQLAlchemy)
- **Authentication:** JWT-based with role-based access control
- **Database:** SQLite (dev) / PostgreSQL (production)
- **API Endpoints:**
  - `/auth/*` - Authentication (signup, login, profile)
  - `/api/jobs` - Job CRUD operations
  - `/api/applications` - Application management
  - `/api/tasks` - Task assignment and tracking
  - `/api/payments` - Payment processing
  - `/api/departments` - Department management
  - `/api/users` - User management
  - `/api/contracts` - Contract management

### Frontend (Flutter Web/Mobile)
- **State Management:** Provider pattern
- **Secure Storage:** flutter_secure_storage for JWT tokens
- **Responsive Design:** Works on web and mobile
- **Real-time Updates:** Pull-to-refresh on all screens
- **Navigation:** Bottom navigation with role-based routing

## 🚀 Key Workflows

### 1. Job Application Flow
1. Admin creates a job in "Manage Jobs"
2. Job appears in Applicant dashboard
3. Job also appears in Worker dashboard (for additional opportunities)
4. Applicant/Worker applies for the job
5. Admin reviews application in "Applications" tab
6. Admin accepts → User role changes to "worker" + assigned to department
7. Admin rejects → Application marked as rejected

### 2. Task Assignment Flow
1. Supervisor views workers in their department
2. Supervisor creates task and assigns to worker
3. Worker sees task in "My Tasks" tab
4. Worker updates progress (Pending → In Progress → Completed)
5. Supervisor monitors task completion

### 3. Payment Processing Flow
1. Admin creates payment for completed tasks
2. Payment appears in Worker's "Payments" tab
3. Admin processes payment in "Payments" tab
4. Payment marked as paid with timestamp

### 4. Department Management Flow
1. Admin creates department
2. Admin assigns supervisor to department
3. Supervisor can view all workers in their department
4. Supervisor assigns tasks to department workers
5. Admin can reassign supervisors or delete departments

## 📊 Database Schema

### Tables
- **users** - All user accounts (applicant, worker, supervisor, admin)
- **departments** - Department structure with supervisor assignments
- **jobs** - Job positions with status (open/closed)
- **applications** - Job applications with status tracking
- **tasks** - Work assignments with progress tracking
- **contracts** - Worker contracts with approval workflow
- **payments** - Payment records with status tracking

### Relationships
- User → Department (many-to-one)
- Department → Supervisor (one-to-one)
- Job → Department (many-to-one)
- Application → User + Job (many-to-one each)
- Task → Worker + Supervisor (many-to-one each)
- Payment → Worker + Task (many-to-one each)

## 🔐 Security Features
- JWT token authentication
- Role-based access control (RBAC)
- Password hashing with Werkzeug
- Secure token storage on client
- API endpoint protection with decorators

## 📱 User Interface Features
- Clean Material Design 3 UI
- Color-coded status indicators
- Pull-to-refresh functionality
- Loading states and error handling
- Confirmation dialogs for destructive actions
- Toast notifications for user feedback
- Responsive cards and lists
- Bottom navigation for easy access

## 🎨 Status Color Coding
- **Green:** Open jobs, Accepted applications, Paid payments, Completed tasks
- **Orange:** Pending applications, In-progress tasks
- **Red:** Rejected applications, Unpaid payments
- **Grey:** Closed jobs

## 🔄 Real-time Updates
- Jobs created by admin instantly appear for applicants and workers
- Jobs deleted by admin are removed from all views
- Application status changes reflect immediately
- Task progress updates sync across supervisor and worker views
- Payment status updates visible to both admin and worker

## 🛠️ Admin Management Tools

### Job Management Screen
- List all jobs (open and closed)
- Create job with title, description, department
- Edit job details and status
- Delete jobs (with confirmation)
- Filter by status
- Visual status indicators

### Department Management Screen
- List all departments with supervisors
- Create department with optional supervisor
- Assign/reassign supervisors
- Edit department names
- Delete departments (with confirmation)
- View supervisor assignments

## 📈 Future Enhancements
- File upload for contracts
- Advanced reporting and analytics
- Email notifications
- Mobile app deployment (Android/iOS)
- Performance reviews
- Attendance tracking
- Leave management
- Document management

## 🧪 Testing Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | hr@county.go.ke | password |
| Supervisor | sup@county.go.ke | password |
| Worker | worker@county.go.ke | password |
| Applicant | applicant@county.go.ke | password |

## 🚦 Getting Started

### Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 seed.py  # Seed database
python3 app.py   # Start server on port 5000
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port=8080  # Web
flutter run -d <device>                # Mobile
```

## 📝 API Documentation
All API endpoints return JSON with standard format:
```json
{
  "status": "success|error",
  "message": "Description",
  "data": {}
}
```

Protected endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

## 🎓 Developer Information
**Developer:** Kelvin Barasa  
**Registration:** DSE-01-8475-2023  
**Institution:** School Project  
**Tech Stack:** Flask + Flutter + SQLite  
**Architecture:** RESTful API + Mobile-First Design
