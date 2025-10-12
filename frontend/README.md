# County Worker Platform - Flutter Frontend

Cross-platform mobile and web application for the County Government Worker Registration and Assignment Platform.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Android Studio / Xcode (for mobile)
- Chrome (for web development)

### Installation

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run

# Run on iOS
flutter run -d ios
```

## 📱 Features by Role

### 🔵 Applicant Dashboard
- **View Jobs**: Browse all open job positions
- **Apply for Jobs**: Submit applications with one click
- **Track Applications**: Monitor status (Pending/Accepted/Rejected)
- **Job Details**: View full job descriptions and requirements

### 🟢 Worker Dashboard
- **My Tasks**: View all assigned tasks
- **Update Progress**: Change task status (Pending → In Progress → Completed)
- **Payment Tracking**: View all payment records
- **Earnings Summary**: See paid and unpaid amounts
- **Contract Access**: View employment contract details

### 🟡 Supervisor Dashboard
- **Task Management**: View all department tasks
- **Assign Tasks**: Create and assign tasks to workers
- **Progress Monitoring**: Track task completion rates
- **Worker Management**: View all workers in department
- **Task Statistics**: See pending, in-progress, and completed tasks

### 🔴 Admin Dashboard
- **System Overview**: Dashboard with key metrics
- **Application Review**: Approve or reject job applications
- **Payment Processing**: Mark payments as paid
- **Job Management**: Create and manage job postings
- **Analytics**: View system-wide statistics

## 🏗️ Architecture

### State Management
- **Provider**: For authentication and global state
- **StatefulWidget**: For local component state

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── job.dart
│   ├── application.dart
│   ├── task.dart
│   └── payment.dart
├── providers/                # State management
│   └── auth_provider.dart
├── services/                 # API integration
│   └── api_service.dart
├── screens/                  # UI screens
│   ├── login.dart
│   ├── signup.dart
│   └── dashboards/
│       ├── applicant_dashboard.dart
│       ├── worker_dashboard.dart
│       ├── supervisor_dashboard.dart
│       └── admin_dashboard.dart
└── widgets/                  # Reusable components
```

## 🔧 Configuration

### API URL Setup

Edit `lib/services/api_service.dart`:

```dart
class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://YOUR_IP:5000';
  // Examples:
  // Local: 'http://localhost:5000'
  // Network: 'http://192.168.1.100:5000'
  // Production: 'https://api.yourcompany.com'
}
```

### Finding Your IP Address

**Linux/Mac:**
```bash
ifconfig | grep "inet "
```

**Windows:**
```bash
ipconfig
```

Use the IP address shown (e.g., 192.168.1.100) in the `baseUrl`.

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI
  cupertino_icons: ^1.0.6
  
  # State Management
  provider: ^6.1.1
  
  # HTTP & API
  http: ^1.1.2
  dio: ^5.4.0
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Navigation
  go_router: ^13.0.0
  
  # Utils
  fluttertoast: ^8.2.4
  intl: ^0.19.0
  
  # Responsive
  responsive_framework: ^1.1.1
```

## 🎨 UI Components

### Material Design 3
- Modern card-based layouts
- Consistent color scheme
- Responsive design
- Bottom navigation
- Floating action buttons

### Key Widgets
- **Cards**: For displaying jobs, tasks, payments
- **ListTiles**: For applications and workers
- **ExpansionTiles**: For task details
- **BottomNavigationBar**: For screen navigation
- **RefreshIndicator**: Pull-to-refresh functionality

## 🔐 Authentication Flow

1. **App Launch**: Check for stored token
2. **Token Found**: Load user profile → Navigate to role-based dashboard
3. **No Token**: Show login screen
4. **Login Success**: Save token → Navigate to dashboard
5. **Logout**: Delete token → Return to login

### Secure Storage
- JWT tokens stored using `flutter_secure_storage`
- Automatic token injection in API requests
- Token validation on app startup

## 📱 Building for Production

### Android APK

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
# Build for web
flutter build web

# Output: build/web/
```

Deploy the `build/web` folder to:
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages

## 🌐 Web Deployment

### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Build and deploy
flutter build web
firebase deploy
```

### Netlify

```bash
# Build
flutter build web

# Drag and drop build/web folder to Netlify
```

## 📱 Mobile Permissions

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Manual Testing Checklist

**Applicant:**
- [ ] Login with applicant credentials
- [ ] View available jobs
- [ ] Apply for a job
- [ ] Check application status

**Worker:**
- [ ] Login with worker credentials
- [ ] View assigned tasks
- [ ] Update task progress
- [ ] View payment records

**Supervisor:**
- [ ] Login with supervisor credentials
- [ ] View department tasks
- [ ] Assign new task to worker
- [ ] Monitor task completion

**Admin:**
- [ ] Login with admin credentials
- [ ] View dashboard statistics
- [ ] Approve/reject applications
- [ ] Process payments

## 🐛 Troubleshooting

### API Connection Issues

**Problem:** "Network error" or "Connection refused"

**Solutions:**
1. Check backend is running (`python app.py`)
2. Verify `baseUrl` in `api_service.dart`
3. Ensure phone/emulator on same network
4. Check firewall settings
5. Use IP address instead of localhost

### Build Errors

```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

### Token Errors

**Problem:** "Invalid token" or "Token expired"

**Solution:**
1. Logout and login again
2. Clear app data
3. Reinstall app

### Android Build Issues

```bash
# Update Gradle
cd android
./gradlew clean

# Return to project root
cd ..
flutter build apk
```

## 📊 Performance Optimization

### Best Practices
1. **Lazy Loading**: Load data only when needed
2. **Caching**: Store frequently accessed data
3. **Image Optimization**: Compress images before upload
4. **Pagination**: Load large lists in chunks
5. **Debouncing**: Delay search API calls

### Code Optimization
```dart
// Use const constructors
const Text('Hello');

// Avoid rebuilds
const SizedBox(height: 16);

// Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

## 🎯 Future Enhancements

- [ ] Push notifications
- [ ] Offline mode with local database
- [ ] File upload for contracts
- [ ] PDF generation for reports
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Biometric authentication
- [ ] In-app messaging
- [ ] Advanced analytics
- [ ] Export data to CSV/Excel

## 📱 Platform-Specific Features

### Android
- Material Design components
- Back button handling
- System navigation bar

### iOS
- Cupertino widgets
- Safe area handling
- iOS-specific gestures

### Web
- Responsive breakpoints
- Browser navigation
- URL routing

## 🔄 State Management Flow

```
User Action → Provider Method → API Service → Backend
                    ↓
              Update State
                    ↓
            Notify Listeners
                    ↓
              UI Rebuilds
```

## 📝 Code Examples

### Making API Calls

```dart
// In a StatefulWidget
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  try {
    final response = await _apiService.getJobs();
    
    if (response['status'] == 'success') {
      setState(() {
        _jobs = (response['jobs'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Using Provider

```dart
// Access auth state
final authProvider = Provider.of<AuthProvider>(context);

// Check authentication
if (authProvider.isAuthenticated) {
  // User is logged in
}

// Get current user
final user = authProvider.currentUser;
```

## 🎨 Customization

### Theme

Edit `main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change primary color
  ),
  useMaterial3: true,
),
```

### App Name

Edit `pubspec.yaml`:

```yaml
name: county_worker_platform
description: County Government Worker Platform
```

## 📞 Support

For issues or questions:
- Check the main README.md
- Review API documentation
- Contact: Kelvin Barasa (DSE-01-8475-2023)

---

**Built with Flutter 💙**
