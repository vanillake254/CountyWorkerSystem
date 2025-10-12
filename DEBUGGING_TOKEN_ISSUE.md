# Debugging Token Issue - Step by Step

## 🔍 What We Changed

### 1. Token Storage Fix
**Changed from:** `flutter_secure_storage` (doesn't work on web)  
**Changed to:** `shared_preferences` (works on web and mobile)

**File:** `/frontend/lib/services/api_service.dart`

### 2. Added Debug Logging
Added console logs to track token flow:
- 🔐 Login attempt
- 📥 Login response
- 🎫 Token received
- 💾 Token saving
- ✅ Token saved confirmation
- 🔑 Token retrieval on each API call

### 3. Added Users Tab
Admin can now see all registered users in a new "Users" tab

---

## 🧪 How to Debug the Token Issue

### Step 1: Open Browser Console
1. Open Chrome DevTools (F12)
2. Go to "Console" tab
3. Clear the console

### Step 2: Login and Watch Console
1. Login as **applicant@county.go.ke** / password
2. Watch for these logs:
   ```
   🔐 Attempting login for: applicant@county.go.ke
   📥 Login response: success
   🎫 Token received: eyJhbGciOiJIUzI1NiIs...
   💾 Saving token: eyJhbGciOiJIUzI1NiIs...
   ✅ Token saved successfully: true
   ```

### Step 3: Try to Apply for a Job
1. Click "Apply Now" on any job
2. Watch for this log:
   ```
   🔑 Token retrieved: YES (eyJhbGciOiJIUzI1NiIs...)
   ```

### Step 4: Check for Errors
If you see "Invalid token", check:
- ❌ Token retrieved: NO → Token not saved properly
- ❌ Token retrieved: YES but still error → Backend JWT issue

---

## 🔧 If Token is Not Being Saved

### Check SharedPreferences
Open browser console and run:
```javascript
// Check if token exists in localStorage
localStorage.getItem('flutter.auth_token')
```

### Clear and Retry
```javascript
// Clear all storage
localStorage.clear()
// Then login again
```

---

## 🔧 If Token is Saved But Still Invalid

### Check Backend JWT Secret
**File:** `/backend/config.py`

Make sure JWT_SECRET_KEY is set:
```python
JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'your-secret-key-here')
```

### Check Token Format
The token should start with: `eyJ...`

If it doesn't, the backend isn't generating JWT tokens correctly.

---

## 🧪 Test Backend Directly

### Test Login Endpoint
```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"applicant@county.go.ke","password":"password"}'
```

Expected response:
```json
{
  "status": "success",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {...}
}
```

### Test Protected Endpoint
```bash
# Replace TOKEN with actual token from login
curl -X GET http://localhost:5000/api/applications \
  -H "Authorization: Bearer TOKEN"
```

Expected response:
```json
{
  "status": "success",
  "applications": [...]
}
```

If you get "Invalid token", the backend JWT validation is failing.

---

## 🔧 Backend JWT Debugging

### Check JWT Configuration
**File:** `/backend/config.py`

```python
class Config:
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'dev-secret-key-change-in-production')
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
```

### Check JWT Initialization
**File:** `/backend/app.py`

```python
from utils.jwt_helper import jwt, init_jwt

def create_app():
    app = Flask(__name__)
    init_jwt(app)  # Must be called
```

### Check Token Generation
**File:** `/backend/routes/auth.py`

```python
from flask_jwt_extended import create_access_token

token = create_access_token(identity=user.id)
```

---

## 🔧 Frontend Token Debugging

### Check Token in Browser Storage
1. Open DevTools → Application tab
2. Look for "Local Storage" → http://localhost:8080
3. Find key: `flutter.auth_token`
4. Value should be a JWT token

### Manual Token Test
Open browser console:
```javascript
// Get token
const token = localStorage.getItem('flutter.auth_token');
console.log('Token:', token);

// Test API call
fetch('http://localhost:5000/api/applications', {
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('Response:', data));
```

---

## 📊 Check Users Tab

### New Feature: Users Tab
Admin dashboard now has a 4th tab: "Users"

**What it shows:**
- All registered users
- Their roles (color-coded)
- Their departments
- Email addresses

**To test:**
1. Login as **hr@county.go.ke** / password
2. Click "Users" tab at bottom
3. Should see all users including:
   - Admin (red badge)
   - Supervisors (blue badge)
   - Workers (green badge)
   - Applicants (orange badge)

**If users list is empty:**
- Check console for: `✅ Loaded X users`
- Check console for errors: `❌ Error loading users: ...`

---

## 🚨 Common Issues and Solutions

### Issue 1: "Invalid token" on every request
**Cause:** Token not being saved or retrieved  
**Solution:** Check browser console logs, verify SharedPreferences is working

### Issue 2: Users tab is empty
**Cause:** API call failing or no users in database  
**Solution:** 
- Check console for errors
- Verify backend is running
- Run `python3 seed.py` to add test users

### Issue 3: Token saved but still invalid
**Cause:** Backend JWT secret mismatch or token expired  
**Solution:**
- Restart backend
- Check JWT_SECRET_KEY in config
- Check token expiration time

### Issue 4: CORS errors
**Cause:** Backend CORS not configured properly  
**Solution:** Already fixed in app.py with:
```python
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
```

---

## ✅ Expected Console Output

### On Login:
```
🔐 Attempting login for: applicant@county.go.ke
📥 Login response: success
🎫 Token received: eyJhbGciOiJIUzI1NiIs...
💾 Saving token: eyJhbGciOiJIUzI1NiIs...
✅ Token saved successfully: true
```

### On API Call:
```
🔑 Token retrieved: YES (eyJhbGciOiJIUzI1NiIs...)
```

### On Loading Users (Admin):
```
✅ Loaded 4 users
```

---

## 🎯 Next Steps

1. **Clear browser cache and storage**
   - DevTools → Application → Clear storage
   - Click "Clear site data"

2. **Restart both services**
   ```bash
   # Backend
   cd backend
   source venv/bin/activate
   python3 app.py
   
   # Frontend
   cd frontend
   flutter run -d chrome --web-port=8080
   ```

3. **Login fresh and check console**
   - Watch for all the emoji logs
   - Take screenshot if error persists

4. **Test the Users tab**
   - Login as admin
   - Go to Users tab
   - Should see all registered users

---

## 📞 If Still Not Working

**Provide this information:**
1. Screenshot of browser console during login
2. Screenshot of browser console when applying for job
3. Screenshot of Application → Local Storage
4. Backend terminal output
5. Screenshot of Users tab (if empty)

This will help identify exactly where the token flow is breaking!
