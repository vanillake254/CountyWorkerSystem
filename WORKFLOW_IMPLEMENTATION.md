# County Worker Platform - Complete Workflow Implementation

## Overview
This document outlines the complete workflow implementation for the County Worker Platform with proper status tracking, salary management, task approval, and payment processing.

## Backend Changes Completed ✅

### 1. Database Models Updated

#### User Model (`models/user.py`)
- Added `salary` field (Float) - Monthly salary assigned by admin
- Added `salary_balance` field (Float) - Remaining unpaid salary
- Updated `to_dict()` to include new fields

#### Task Model (`models/task.py`)
- Changed `progress_status` default from 'pending' to 'incomplete'
- Status flow: `incomplete` → `completed` → `approved`/`denied`
- Added `approved_at` field (DateTime) - When supervisor approves/denies
- Added `supervisor_comment` field (Text) - Comment when approving/denying
- Updated `to_dict()` to include new fields

#### Payment Model (`models/payment.py`)
- No changes needed - already has amount and status fields

### 2. API Routes Updated

#### Application Routes (`routes/application.py`)
**PUT /api/applications/:id** - Accept/Reject Application
- When accepting, admin MUST provide:
  - `salary` (required) - Monthly salary amount
  - `department_id` (required) - Department assignment
- System automatically:
  - Changes user role to 'worker'
  - Sets salary and salary_balance
  - Assigns to department

#### Task Routes (`routes/task.py`)
**POST /api/tasks** - Create Task
- Initial status: `incomplete`

**PUT /api/tasks/:id** - Update Task
- **Workers**: Can only mark as `completed`
- **Supervisors**: Can approve/deny completed tasks
  - Status: `approved` or `denied`
  - Optional: `supervisor_comment`
- **Admins**: Can update any status

#### Payment Routes (`routes/payment.py`)
**PUT /api/payments/:id** - Process Payment
- Admin can update `amount` before marking as paid
- When marking as `paid`:
  - Deducts amount from worker's `salary_balance`
  - Sets `paid_at` timestamp
  - Records payment in database

### 3. Seed Data Updated (`seed.py`)
- Workers now have salary and salary_balance
- Tasks use 'incomplete' status instead of 'pending'

## Complete Workflow

### 1. Job Application Flow
```
1. Applicant views open jobs
2. Applicant applies → Status: "pending"
3. Admin reviews application
4. Admin accepts:
   - Enters salary amount (e.g., 25000)
   - Selects department
   - Selects supervisor (optional)
   → User becomes "worker" with salary_balance = salary
5. Admin rejects → Status: "rejected"
```

### 2. Task Assignment & Completion Flow
```
1. Supervisor logs in
2. Views workers in their department
3. Creates task:
   - Title, description
   - Assigns to worker
   - Sets start/end dates
   → Status: "incomplete"

4. Worker logs in
5. Sees task with status "incomplete"
6. Completes work
7. Marks task as "completed"
   → Status: "completed", completed_at set

8. Supervisor reviews completed task
9. Supervisor approves or denies:
   - Approve → Status: "approved", approved_at set
   - Deny → Status: "denied", can add comment
   
10. Worker sees updated status
```

### 3. Payment Processing Flow
```
1. Admin sees approved tasks
2. Admin creates payment record:
   - Selects worker
   - Links to task (optional)
   - Enters amount (e.g., 5000)
   → Status: "unpaid"

3. Worker sees payment in "Payments" tab
   - Amount: 5000
   - Status: Unpaid
   - Salary Balance: 25000

4. Admin processes payment:
   - Reviews payment
   - Clicks "Pay"
   → Status: "paid"
   → Worker's salary_balance: 25000 - 5000 = 20000
   → paid_at timestamp set

5. Worker sees updated payment:
   - Status: Paid
   - New Salary Balance: 20000
```

## Frontend Changes Needed

### Flutter Models to Update

#### 1. User Model (`models/user.dart`)
```dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? departmentId;
  final String? departmentName;
  final double? salary;              // ADD THIS
  final double? salaryBalance;       // ADD THIS
  final String createdAt;
}
```

#### 2. Task Model (`models/task.dart`)
```dart
class Task {
  final int id;
  final String title;
  final String description;
  final int assignedTo;
  final String? workerName;
  final int supervisorId;
  final String? supervisorName;
  final String progressStatus;       // incomplete, completed, approved, denied
  final String startDate;
  final String endDate;
  final String createdAt;
  final String? completedAt;
  final String? approvedAt;          // ADD THIS
  final String? supervisorComment;   // ADD THIS
}
```

### API Service Updates (`services/api_service.dart`)

#### Update Application Approval
```dart
Future<Map<String, dynamic>> updateApplication(
  int applicationId, 
  String status,
  {double? salary, int? departmentId}  // ADD THESE
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/applications/$applicationId'),
    headers: await _getHeaders(),
    body: jsonEncode({
      'status': status,
      if (salary != null) 'salary': salary,
      if (departmentId != null) 'department_id': departmentId,
    }),
  );
  return jsonDecode(response.body);
}
```

#### Add Task Approval Method
```dart
Future<Map<String, dynamic>> approveTask(
  int taskId,
  String status,  // 'approved' or 'denied'
  {String? comment}
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/tasks/$taskId'),
    headers: await _getHeaders(),
    body: jsonEncode({
      'progress_status': status,
      if (comment != null) 'supervisor_comment': comment,
    }),
  );
  return jsonDecode(response.body);
}
```

#### Update Payment Processing
```dart
Future<Map<String, dynamic>> processPayment(
  int paymentId,
  double amount,
  String status
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/payments/$paymentId'),
    headers: await _getHeaders(),
    body: jsonEncode({
      'amount': amount,
      'status': status,
    }),
  );
  return jsonDecode(response.body);
}
```

### Dashboard Updates Required

#### 1. Admin Dashboard
**Applications Tab:**
- When accepting application, show dialog:
  - Salary input field (number)
  - Department dropdown
  - Accept button

**Payments Tab:**
- Show approved tasks
- For each payment:
  - Amount input field (editable)
  - Worker name, task title
  - Salary balance display
  - "Pay" button

#### 2. Supervisor Dashboard
**Tasks Tab:**
- Show all tasks in department
- For completed tasks, show:
  - "Approve" button
  - "Deny" button
  - Comment field (optional)
- Color coding:
  - Incomplete: Orange
  - Completed: Blue
  - Approved: Green
  - Denied: Red

#### 3. Worker Dashboard
**Tasks Tab:**
- Show assigned tasks
- Display status with colors
- For incomplete tasks: "Mark Complete" button
- Show supervisor comments if denied

**Payments Tab:**
- Show salary and salary balance at top
- List all payments with status
- Show running balance

#### 4. Applicant Dashboard
**Applications Tab:**
- Clear status indicators:
  - Pending: Orange badge
  - Accepted: Green badge with checkmark
  - Rejected: Red badge with X

## Database Migration

Run this to update existing database:
```bash
cd backend
python seed.py  # This will recreate database with new schema
```

## Testing Checklist

- [ ] Applicant can apply for job
- [ ] Admin can accept with salary assignment
- [ ] Worker role is assigned correctly
- [ ] Supervisor can create tasks
- [ ] Worker can mark tasks complete
- [ ] Supervisor can approve/deny tasks
- [ ] Admin can see approved tasks
- [ ] Admin can process payments with amount
- [ ] Salary balance decreases correctly
- [ ] All status updates reflect in real-time

## Deployment Steps

1. Update backend on Railway
2. Run database migration
3. Build new Flutter APK
4. Test complete workflow
5. Deploy to production

---

**Status:** Backend Complete ✅ | Frontend In Progress 🔄
**Next Steps:** Update Flutter models and dashboards
