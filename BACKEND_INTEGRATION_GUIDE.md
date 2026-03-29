# Backend-Frontend Integration Guide

Connect your Flutter app to the Node.js backend.

## 🔗 Connection Setup

### Step 1: Update Backend URL

**File:** `lib/infrastructure/api/api_provider.dart`

**Change this line:**
```dart
static const String baseUrl = 'https://your-backend-api.com/api/v1';
```

**To your deployed server URL:**
```dart
// Development (local)
static const String baseUrl = 'http://localhost:5000/api/v1';

// Or Production (deployed)
static const String baseUrl = 'https://your-app-name.onrender.com/api/v1';
```

### Step 2: Ensure Dio is Installed

```bash
flutter pub add dio
```

✅ Already done! Dio ^5.4.0 is in pubspec.yaml

### Step 3: Test Connection

#### Option A: Make a Test API Call
```bash
flutter run
```

Then navigate to a screen that calls the API. Check console for response.

#### Option B: Quick Test with Postman
```bash
# Health check
GET http://localhost:5000/health

# Get trainers
GET http://localhost:5000/api/v1/trainers?limit=5
```

---

## 📡 How It Works

### Request Flow

```
Flutter App
    ↓
ApiClient (Dio HTTP client)
    ↓
Interceptors:
  - AuthInterceptor: Adds Firebase token
  - LoggingInterceptor: Logs requests
  - ErrorInterceptor: Handles errors
    ↓
Node.js Backend (Express)
    ↓
Middleware:
  - verifyToken: Validates Firebase token
  - verifyAdmin: Checks admin role
    ↓
Database Service (Firestore)
    ↓
Response back to Flutter
```

### Authentication

The `AuthInterceptor` automatically adds your Firebase token:

```dart
// In: lib/infrastructure/api/api_client.dart
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

All backend endpoints receive this token automatically! ✨

---

## 🧪 Test Scenarios

### Scenario 1: Register & Login

```dart
// In your controller
final userRepo = Get.find<UserRepository>();

// Register (done on client via Flutter)
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123'
);

// Login (also on client)
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123'
);

// Backend creates user profile automatically via Cloud Functions
// Or call: POST /api/v1/auth/profile to sync profile
final profile = await userRepo.getProfile();
print(profile); // User profile from backend ✅
```

### Scenario 2: Get Trainers

```dart
final trainerRepo = Get.find<TrainerRepository>();

final response = await trainerRepo.getTrainers(
  limit: 10,
  offset: 0,
  speciality: 'Strength Training'
);

print(response.data);  // List of trainers ✅
```

### Scenario 3: Create Booking

```dart
final bookingRepo = Get.find<BookingRepository>();

final response = await bookingRepo.createBooking(
  trainerId: 'trainer123',
  availabilityId: 'slot456',
  date: DateTime.now().add(Duration(days: 3)),
  startTime: '10:00 AM',
  endTime: '11:00 AM',
  price: 50.0
);

if (response.success) {
  print('Booking created: ${response.data?.bookingId}'); ✅
} else {
  print('Error: ${response.error?.message}'); ❌
}
```

---

## 📋 API Integration Checklist

### Users/Authentication
- [ ] Register works
- [ ] Login works
- [ ] Get user profile works
- [ ] Update profile works
- [ ] Logout works

### Trainers
- [ ] Get trainers list works
- [ ] Filter by speciality works
- [ ] Get trainer details works
- [ ] Get availability slots works
- [ ] Post review works

### Bookings
- [ ] Create booking works
- [ ] Get user bookings works
- [ ] Cancel booking works
- [ ] Record payment works

### Admin (if applicable)
- [ ] Approve trainer application works
- [ ] Get dashboard stats works
- [ ] Ban/unban user works

---

## 🐛 Debugging

### Enable Logging

Already configured in `api_client.dart`:

```dart
// See all requests/responses in console
_dio.interceptors.add(_LoggingInterceptor());
```

### Check Backend Logs

**If running locally:**
```
Terminal shows:
[timestamp] POST /api/v1/bookings
[Response] {"success": true, "data": {...}}
```

**If on Render:**
- Go to Render dashboard
- Click on your service
- View "Logs" tab

### Common Issues

| Error | Cause | Fix |
|-------|-------|-----|
| 401 Unauthorized | No token or expired token | Ensure user is logged in, token valid |
| 403 Forbidden | User doesn't have permission | Check user role on backend |
| 404 Not Found | Wrong API endpoint | Verify URL in `api_provider.dart` |
| CORS Error | Frontend domain not allowed | Add frontend URL to CORS in backend |
| Connection Refused | Backend not running | Start backend: `npm run dev` |

---

## 🔄 Making API Calls

### Example 1: In Controller

```dart
import 'package:get/get.dart';
import 'package:gym_trainer/infrastructure/api/repositories.dart';

class TrainersController extends GetxController {
  final _trainerRepo = Get.find<TrainerRepository>();
  
  final trainers = <TrainerDto>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrainers();
  }

  void loadTrainers() async {
    isLoading.value = true;
    
    final response = await _trainerRepo.getTrainers(limit: 20);
    
    if (response.success) {
      trainers.value = response.data ?? [];
    } else {
      Get.snackbar('Error', response.error?.message ?? 'Unknown error');
    }
    
    isLoading.value = false;
  }
}
```

### Example 2: In Binding

```dart
class TrainersBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories already registered in ApiServiceProvider
    Get.put(TrainersController());
  }
}
```

### Example 3: In View

```dart
class TrainersPage extends GetView<TrainersController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => 
        controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: controller.trainers.length,
              itemBuilder: (context, index) {
                final trainer = controller.trainers[index];
                return TrainerCard(trainer: trainer);
              }
            )
      )
    );
  }
}
```

---

## 🚀 Production Deployment Flow

1. **Backend Deployed** (e.g., Render)
   - Base URL: `https://app.onrender.com/api/v1`
   - All endpoints live

2. **Firebase Configured**
   - Authentication working
   - Firestore collections set up
   - Service account configured

3. **Flutter App Updated**
   ```dart
   static const String baseUrl = 'https://app.onrender.com/api/v1';
   ```

4. **Build & Release**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

5. **Deploy to Store**
   - Google Play Store
   - Apple App Store

---

## 📊 Monitoring Production

### Check Backend Health
```bash
curl https://your-app.onrender.com/health
```

### Monitor Errors
- Render Dashboard → Logs
- Firestore Console → Monitoring

### User Feedback
- Track crashes with Crashlytics in Firebase
- Monitor API response times

---

## 🎯 Integration Status

- ✅ Dio dependency added
- ✅ ApiClient configured with Firebase auth
- ✅ Repositories ready (User, Trainer, Booking)
- ✅ Example controllers provided
- ✅ Error handling in place
- ⏳ Backend needs to be deployed
- ⏳ Base URL needs to be updated

**Final Step:** Deploy backend, update base URL, and test! 🚀

---

## 📚 Reference Files

- Flutter API Client: `lib/infrastructure/api/`
- Backend API: `backend/src/routes/`
- Example Controllers: `lib/app/modules/example_api_controllers.dart`
- Backend Docs: `backend/BACKEND_README.md`
- Deployment Guide: `backend/DEPLOYMENT_GUIDE.md`

**Everything is ready! Deploy the backend and connect! 🎉**
