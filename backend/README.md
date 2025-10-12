# County Worker Platform - Backend API

Flask-based RESTful API for the County Government Worker Registration and Assignment Platform.

## 🚀 Quick Start

### Installation

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# OR
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

The API will be available at `http://localhost:5000`

### Seed Database

```bash
python seed.py
```

This creates:
- 5 Departments (Sanitation, Water & Infrastructure, Administration, Health Services, Public Works)
- 7 Sample Users (Admin, Supervisors, Workers, Applicants)
- 4 Sample Jobs
- 3 Sample Applications
- 3 Sample Tasks
- 2 Sample Contracts
- 3 Sample Payments

## 📋 API Documentation

### Base URL
```
http://localhost:5000
```

### Authentication

All protected endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

### Endpoints

#### Health Check
```http
GET /
GET /health
```

#### Authentication
```http
POST /auth/signup
Content-Type: application/json

{
  "full_name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response:
{
  "status": "success",
  "token": "eyJhbGc...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "applicant",
    "department_id": null
  }
}
```

```http
GET /auth/profile
Authorization: Bearer <token>
```

#### Jobs
```http
GET /api/jobs?status=open
GET /api/jobs/<id>
POST /api/jobs (admin only)
PUT /api/jobs/<id> (admin only)
DELETE /api/jobs/<id> (admin only)
```

#### Applications
```http
GET /api/applications
POST /api/applications
PUT /api/applications/<id> (admin only)
DELETE /api/applications/<id>
```

#### Tasks
```http
GET /api/tasks
POST /api/tasks (supervisor/admin)
PUT /api/tasks/<id>
DELETE /api/tasks/<id> (supervisor/admin)
```

#### Payments
```http
GET /api/payments
POST /api/payments (admin only)
PUT /api/payments/<id> (admin only)
DELETE /api/payments/<id> (admin only)
```

#### Contracts
```http
GET /api/contracts
POST /api/contracts (admin only)
PUT /api/contracts/<id> (admin only)
DELETE /api/contracts/<id> (admin only)
```

#### Departments
```http
GET /api/departments
GET /api/departments/<id>
GET /api/departments/<id>/workers
POST /api/departments (admin only)
PUT /api/departments/<id> (admin only)
DELETE /api/departments/<id> (admin only)
```

## 🗄️ Database Models

### User
- `id`: Integer (Primary Key)
- `full_name`: String(100)
- `email`: String(120) - Unique, Indexed
- `password_hash`: String(255)
- `role`: String(20) - applicant, worker, supervisor, admin
- `department_id`: Integer (Foreign Key)
- `created_at`: DateTime

### Department
- `id`: Integer (Primary Key)
- `name`: String(100) - Unique
- `supervisor_id`: Integer (Foreign Key)
- `created_at`: DateTime

### Job
- `id`: Integer (Primary Key)
- `title`: String(200)
- `description`: Text
- `department_id`: Integer (Foreign Key)
- `status`: String(20) - open, closed
- `created_at`: DateTime

### Application
- `id`: Integer (Primary Key)
- `applicant_id`: Integer (Foreign Key)
- `job_id`: Integer (Foreign Key)
- `status`: String(20) - pending, accepted, rejected
- `applied_at`: DateTime
- `reviewed_at`: DateTime

### Task
- `id`: Integer (Primary Key)
- `title`: String(200)
- `description`: Text
- `assigned_to`: Integer (Foreign Key)
- `supervisor_id`: Integer (Foreign Key)
- `progress_status`: String(20) - pending, in_progress, completed
- `start_date`: DateTime
- `end_date`: DateTime
- `created_at`: DateTime
- `completed_at`: DateTime

### Contract
- `id`: Integer (Primary Key)
- `worker_id`: Integer (Foreign Key)
- `file_url`: String(500)
- `start_date`: DateTime
- `end_date`: DateTime
- `approved_by`: Integer (Foreign Key)
- `created_at`: DateTime

### Payment
- `id`: Integer (Primary Key)
- `worker_id`: Integer (Foreign Key)
- `task_id`: Integer (Foreign Key)
- `amount`: Float
- `status`: String(20) - unpaid, paid
- `date`: DateTime
- `paid_at`: DateTime

## 🔐 Security

### Password Hashing
Passwords are hashed using Werkzeug's `generate_password_hash` with default settings.

### JWT Tokens
- Tokens expire after 24 hours
- Secret key should be changed in production
- Tokens are validated on protected routes

### Role-Based Access Control
- `@role_required('admin')` - Admin only
- `@role_required('supervisor', 'admin')` - Supervisor or Admin
- `@jwt_required()` - Any authenticated user

## 🔧 Configuration

### Environment Variables
Create a `.env` file:
```env
SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here
DATABASE_URL=sqlite:///county_worker.db
FLASK_ENV=development
```

### Database Configuration
- **Development**: SQLite (`county_worker.db`)
- **Production**: PostgreSQL (update `DATABASE_URL`)

## 📦 Dependencies

```
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
Flask-JWT-Extended==4.6.0
Flask-CORS==4.0.0
Flask-Migrate==4.0.5
python-dotenv==1.0.0
Werkzeug==3.0.1
psycopg2-binary==2.9.9
```

## 🧪 Testing

### Manual Testing with curl

**Login:**
```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hr@county.go.ke","password":"password"}'
```

**Get Jobs:**
```bash
curl http://localhost:5000/api/jobs
```

**Get Profile (with token):**
```bash
curl http://localhost:5000/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🚢 Deployment

### Production Setup

1. **Update Configuration:**
   - Change `SECRET_KEY` and `JWT_SECRET_KEY`
   - Use PostgreSQL instead of SQLite
   - Set `FLASK_ENV=production`

2. **Install Production Server:**
```bash
pip install gunicorn
```

3. **Run with Gunicorn:**
```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Docker Deployment

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

Build and run:
```bash
docker build -t county-worker-api .
docker run -p 5000:5000 county-worker-api
```

## 🐛 Troubleshooting

### Database Issues
```bash
# Delete database and recreate
rm county_worker.db
python seed.py
```

### Port Already in Use
```bash
# Find process using port 5000
lsof -i :5000
# Kill the process
kill -9 <PID>
```

### Import Errors
```bash
# Ensure virtual environment is activated
source venv/bin/activate
# Reinstall dependencies
pip install -r requirements.txt
```

## 📝 Sample Data

After running `seed.py`, test with these credentials:

| Role | Email | Password |
|------|-------|----------|
| Admin | hr@county.go.ke | password |
| Supervisor | sup@county.go.ke | password |
| Worker | worker@county.go.ke | password |
| Applicant | applicant@county.go.ke | password |

## 🔄 Database Migrations

Using Flask-Migrate:

```bash
# Initialize migrations
flask db init

# Create migration
flask db migrate -m "Initial migration"

# Apply migration
flask db upgrade
```

## 📊 API Response Format

### Success Response
```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description"
}
```

## 🛡️ Best Practices

1. **Always use HTTPS in production**
2. **Validate all user inputs**
3. **Use environment variables for secrets**
4. **Implement rate limiting for production**
5. **Enable CORS only for trusted origins**
6. **Regular database backups**
7. **Monitor API performance**
8. **Keep dependencies updated**

---

**Developer:** Kelvin Barasa (DSE-01-8475-2023)
