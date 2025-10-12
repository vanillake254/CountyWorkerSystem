# County Government Worker Registration and Assignment Platform

**Developer:** Kelvin Barasa (DSE-01-8475-2023)  
**Stack:** Flutter (Frontend + Web) + Flask (Backend API) + SQLite/PostgreSQL (DB)

A comprehensive multi-role system for managing county job recruitment, assignment, and payroll.

---

## 📋 Project Overview

The County Worker Platform is a complete digital solution for managing temporary and contract-based county workers. It provides role-based access for Applicants, Workers, Supervisors, and HR/Admin personnel.

### Key Features

- **Multi-Role Authentication**: JWT-based authentication with role-specific dashboards
- **Job Management**: Create, view, and apply for county job positions
- **Application Processing**: HR can review and approve/reject applications
- **Task Assignment**: Supervisors assign and track worker tasks
- **Payment Management**: Track and process worker payments
- **Contract Management**: Upload and manage worker contracts
- **Department Management**: Organize workers by departments

---

## 🏗️ Architecture

### Backend (Flask + Python)
- RESTful API with JWT authentication
- SQLAlchemy ORM for database operations
- Role-based access control (RBAC)
- Comprehensive error handling
- CORS enabled for cross-origin requests

### Frontend (Flutter)
- Cross-platform support (Android, iOS, Web)
- Material Design 3 UI
- Provider state management
- Secure token storage
- Role-based navigation

### Database (SQLite/PostgreSQL)
- 7 main tables: Users, Departments, Jobs, Applications, Tasks, Contracts, Payments
- Foreign key relationships
- Indexed fields for performance

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Flutter 3.0+
- pip (Python package manager)
- Android Studio / Xcode (for mobile development)

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

The backend will start on `http://localhost:5000`

### Seed Database with Sample Data

```bash
# Make sure virtual environment is activated
python seed.py
```

This creates sample users:
- **Admin**: hr@county.go.ke / password
- **Supervisor**: sup@county.go.ke / password
- **Worker**: worker@county.go.ke / password
- **Applicant**: applicant@county.go.ke / password

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Update API URL in lib/services/api_service.dart
# Change baseUrl to your backend URL (default: http://192.168.100.4:5000)

# Run on web
flutter run -d chrome

# Run on Android
flutter run

# Build APK
flutter build apk --release
```

---

## 📱 User Roles & Features

### 1️⃣ Applicant
- View open job positions
- Apply for jobs
- Track application status (Pending/Accepted/Rejected)
- View job details and requirements

### 2️⃣ Worker
- View assigned tasks
- Update task progress (Pending → In Progress → Completed)
- View payment records
- Track earnings (Paid/Unpaid)
- View contract details

### 3️⃣ Supervisor
- View all tasks in department
- Assign tasks to workers
- Track task progress
- View department workers
- Monitor task completion rates

### 4️⃣ HR/Admin
- Review and approve/reject applications
- Manage job postings
- Process payments
- View system analytics
- Manage departments
- Upload contracts

---

## 🔌 API Endpoints

### Authentication
```
POST   /auth/signup        - Create new account
POST   /auth/login         - Authenticate user
GET    /auth/profile       - Get user profile (JWT required)
```

### Jobs
```
GET    /api/jobs           - List all jobs
POST   /api/jobs           - Create job (admin only)
PUT    /api/jobs/:id       - Update job (admin only)
DELETE /api/jobs/:id       - Delete job (admin only)
```

### Applications
```
GET    /api/applications   - Get applications (role-filtered)
POST   /api/applications   - Apply for job
PUT    /api/applications/:id - Update status (admin only)
DELETE /api/applications/:id - Withdraw application
```

### Tasks
```
GET    /api/tasks          - Get tasks (role-filtered)
POST   /api/tasks          - Create task (supervisor/admin)
PUT    /api/tasks/:id      - Update task progress
DELETE /api/tasks/:id      - Delete task (supervisor/admin)
```

### Payments
```
GET    /api/payments       - Get payments (role-filtered)
POST   /api/payments       - Create payment (admin only)
PUT    /api/payments/:id   - Update payment status (admin only)
DELETE /api/payments/:id   - Delete payment (admin only)
```

### Contracts
```
GET    /api/contracts      - Get contracts (role-filtered)
POST   /api/contracts      - Create contract (admin only)
PUT    /api/contracts/:id  - Update contract (admin only)
DELETE /api/contracts/:id  - Delete contract (admin only)
```

### Departments
```
GET    /api/departments    - List all departments
POST   /api/departments    - Create department (admin only)
PUT    /api/departments/:id - Update department (admin only)
DELETE /api/departments/:id - Delete department (admin only)
GET    /api/departments/:id/workers - Get department workers
```

---

## 🗄️ Database Schema

### Users
- id, full_name, email, password_hash, role, department_id, created_at

### Departments
- id, name, supervisor_id, created_at

### Jobs
- id, title, description, department_id, status, created_at

### Applications
- id, applicant_id, job_id, status, applied_at, reviewed_at

### Tasks
- id, title, description, assigned_to, supervisor_id, progress_status, start_date, end_date, created_at, completed_at

### Contracts
- id, worker_id, file_url, start_date, end_date, approved_by, created_at

### Payments
- id, worker_id, task_id, amount, status, date, paid_at

---

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Werkzeug security for password encryption
- **Role-Based Access Control**: Endpoint-level permission checks
- **CORS Protection**: Configured for specific origins
- **Input Validation**: Server-side validation for all inputs
- **Secure Storage**: Flutter secure storage for tokens

---

## 📊 Workflow Examples

### Job Application Flow
1. Applicant views open jobs
2. Applicant applies for job
3. Application status: "Pending"
4. HR reviews application
5. HR accepts/rejects application
6. If accepted, applicant role changes to "worker"

### Task Assignment Flow
1. Supervisor selects worker
2. Supervisor creates task with details
3. Worker receives task (status: "Pending")
4. Worker updates progress to "In Progress"
5. Worker completes task (status: "Completed")
6. Supervisor verifies completion

### Payment Processing Flow
1. Admin creates payment record for worker
2. Payment status: "Unpaid"
3. Admin verifies task completion
4. Admin marks payment as "Paid"
5. Worker sees updated payment status

---

## 🛠️ Development

### Backend Structure
```
backend/
├── app.py                 # Main Flask application
├── config.py              # Configuration settings
├── seed.py                # Database seeding script
├── requirements.txt       # Python dependencies
├── models/                # Database models
│   ├── user.py
│   ├── department.py
│   ├── job.py
│   ├── application.py
│   ├── task.py
│   ├── contract.py
│   └── payment.py
├── routes/                # API routes
│   ├── auth.py
│   ├── job.py
│   ├── application.py
│   ├── task.py
│   ├── contract.py
│   ├── payment.py
│   └── department.py
└── utils/                 # Utilities
    ├── db.py
    ├── jwt_helper.py
    └── role_checker.py
```

### Frontend Structure
```
frontend/
├── lib/
│   ├── main.dart          # App entry point
│   ├── models/            # Data models
│   ├── providers/         # State management
│   ├── services/          # API service
│   ├── screens/           # UI screens
│   │   ├── login.dart
│   │   ├── signup.dart
│   │   └── dashboards/
│   │       ├── applicant_dashboard.dart
│   │       ├── worker_dashboard.dart
│   │       ├── supervisor_dashboard.dart
│   │       └── admin_dashboard.dart
│   └── widgets/           # Reusable widgets
└── pubspec.yaml           # Flutter dependencies
```

---

## 🚢 Deployment

### Backend Deployment

**Option 1: Local/Development**
```bash
python app.py
```

**Option 2: Production (Gunicorn)**
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

**Option 3: Docker**
```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

### Frontend Deployment

**Web Deployment**
```bash
flutter build web
# Deploy the build/web folder to hosting service
```

**Android APK**
```bash
flutter build apk --release
# APK located at build/app/outputs/flutter-apk/app-release.apk
```

**iOS Build**
```bash
flutter build ios --release
```

---

## 🔧 Configuration

### Backend Configuration (config.py)
- `SECRET_KEY`: Flask secret key
- `JWT_SECRET_KEY`: JWT token secret
- `DATABASE_URL`: Database connection string
- `UPLOAD_FOLDER`: File upload directory

### Frontend Configuration (api_service.dart)
- `baseUrl`: Backend API URL
- Update this to match your backend deployment URL

---

## 📝 Testing

### Test User Credentials
After running `seed.py`, use these credentials:

| Role | Email | Password |
|------|-------|----------|
| Admin | hr@county.go.ke | password |
| Supervisor | sup@county.go.ke | password |
| Worker | worker@county.go.ke | password |
| Applicant | applicant@county.go.ke | password |

---

## 🐛 Troubleshooting

### Backend Issues
- **Port already in use**: Change port in `app.py`
- **Database errors**: Delete `county_worker.db` and run `seed.py` again
- **Import errors**: Ensure virtual environment is activated

### Frontend Issues
- **API connection failed**: Update `baseUrl` in `api_service.dart`
- **Build errors**: Run `flutter clean` then `flutter pub get`
- **Token errors**: Clear app data or reinstall

---

## 📄 License

This project is developed for educational purposes.

**Developer:** Kelvin Barasa  
**Student ID:** DSE-01-8475-2023  
**Institution:** [Your Institution Name]

---

## 🙏 Acknowledgments

- Flask framework for backend API
- Flutter framework for cross-platform development
- SQLAlchemy for database ORM
- Material Design for UI components

---

## 📞 Support

For issues or questions, contact:
- **Developer:** Kelvin Barasa
- **Email:** [Your Email]
- **GitHub:** [Your GitHub Profile]

---

**Built with ❤️ by Kelvin Barasa**
