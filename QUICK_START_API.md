# 🚀 Professional API Setup - Quick Start Guide

## What You Just Got

A complete, production-ready API integration architecture with:
- ✅ Type-safe HTTP client (Dio)
- ✅ Automatic Firebase auth token injection
- ✅ Request/response logging
- ✅ Global error handling
- ✅ Repository pattern for clean architecture
- ✅ GetX integration for dependency injection
- ✅ Pagination support
- ✅ Strong typing with DTOs

---

## File Structure

```
lib/
├── infrastructure/api/
│   ├── api_client.dart         # HTTP client with interceptors
│   ├── api_models.dart         # Request/Response models
│   ├── api_provider.dart       # GetX dependency injection
│   └── repositories.dart       # Data repositories (User, Trainer, Booking)
│
└── app/modules/
    └── example_api_controllers.dart  # Example implementations

Root:
└── API_IMPLEMENTATION_GUIDE.md  # Full documentation
```

---

## Installation Steps

### 1️⃣ Add Dependencies to `pubspec.yaml`

```yaml
dependencies:
  dio: ^5.0.0
  get: ^4.7.3
```

Run: `flutter pub get`

### 2️⃣ Update Backend URL

In `lib/infrastructure/api/api_models.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-actual-backend.com/api/v1';
  // Update with your real API URL
}
```

### 3️⃣ Initialize in `main.dart`

```dart
import 'package:gym_trainer/infrastructure/api/api_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await Supabase.initialize(...);
  
  // Add this line:
  await ApiServiceProvider.initialize();
  
  // ... rest of main
}
```

### 4️⃣ Use in Controllers

```dart
import 'package:get/get.dart';
import 'package:gym_trainer/infrastructure/api/repositories.dart';

class MyController extends GetxController {
  final _userRepo = Get.find<UserRepository>();
  final user = Rxn<UserProfileDto>();
  final isLoading = false.obs;

  Future<void> loadProfile() async {
    isLoading(true);
    final response = await _userRepo.getProfile();
    
    if (response.success) {
      user.value = response.data;
    } else {
      print('Error: ${response.error}');
    }
    
    isLoading(false);
  }
}
```

---

## Common API Patterns

### 🔍 Fetching Data (GETs)
```dart
final response = await _userRepo.getProfile();

if (response.success && response.data != null) {
  // Use response.data
}
```

### ➕ Creating Data (POSTs)
```dart
final request = CreateBookingRequest(
  trainerId: 'trainer123',
  scheduledAt: DateTime.now(),
  durationMinutes: 60,
);

final response = await _bookingRepo.createBooking(request);
if (response.success) {
  // Success
}
```

### ✏️ Updating Data (PUTs)
```dart
final request = UpdateProfileRequest(
  name: 'John Doe',
  bio: 'Fitness enthusiast',
);

final response = await _userRepo.updateProfile(request);
```

### 🗑️ Deleting Data (DELETEs)
```dart
final response = await _bookingRepo.cancelBooking(bookingId);
```

### 📄 Pagination
```dart
final response = await _trainerRepo.getTrainers(
  page: 1,
  pageSize: 20,
  specialization: 'CrossFit',
);

if (response.success && response.data != null) {
  final trainers = response.data!.items;
  final hasMore = response.data!.hasMore;
}
```

---

## Error Handling Patterns

### Pattern 1: Simple Check
```dart
final response = await repo.fetchData();

if (!response.success) {
  Get.snackbar('Error', response.error ?? 'Unknown error');
  return;
}
```

### Pattern 2: Try-Catch with Logging
```dart
try {
  final response = await repo.fetchData();
  
  if (response.success) {
    // Handle success
  } else {
    // Handle API error
    debugPrint('API Error: ${response.error}');
  }
} catch (e) {
  // Network or other errors
  GET.snackbar('Error', 'Network error: $e');
}
```

### Pattern 3: Loading States
```dart
final isLoading = false.obs;
final error = ''.obs;
final data = Rxn<MyData>();

Future<void> fetch() async {
  isLoading(true);
  error('');
  
  try {
    final response = await repo.fetch();
    
    if (response.success) {
      data.value = response.data;
    } else {
      error.value = response.error ?? 'Failed to load';
    }
  } catch (e) {
    error.value = 'Error: $e';
  } finally {
    isLoading(false);
  }
}
```

---

## Adding New API Endpoints

### Step 1: Add Endpoint to `ApiConstants`
```dart
class ApiConstants {
  static const String myNewEndpoint = '/my/new/endpoint';
}
```

### Step 2: Create DTO
```dart
class MyDataDto {
  final String id;
  final String name;

  MyDataDto({required this.id, required this.name});

  factory MyDataDto.fromJson(Map<String, dynamic> json) {
    return MyDataDto(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

### Step 3: Add to Repository
```dart
class MyRepository {
  final ApiClient _apiClient;

  MyRepository(this._apiClient);

  Future<ApiResponse<MyDataDto>> fetch() async {
    final response = await _apiClient.get(
      ApiConstants.myNewEndpoint,
    );
    return ApiResponse.fromJson(
      response as Map<String, dynamic>,
      (json) => MyDataDto.fromJson(json),
    );
  }
}
```

### Step 4: Register in `ApiServiceProvider`
```dart
Get.put<MyRepository>(MyRepository(Get.find<ApiClient>()));
```

### Step 5: Use in Controller
```dart
final _repo = Get.find<MyRepository>();
final response = await _repo.fetch();
```

---

## Troubleshooting

### ❌ "No Firebase App created"
- Ensure `Firebase.initializeApp()` is called **before** `ApiServiceProvider.initialize()`

### ❌ "401 Unauthorized"
- Check that user is logged in
- Verify Firebase ID token is valid
- Token refresh is automatic via interceptor

### ❌ "Network timeout"
- Check internet connection
- Increase timeout in `ApiClient`:
  ```dart
  ApiClient(
    baseUrl: url,
    connectTimeout: const Duration(seconds: 60),
  )
  ```

### ❌ "CORS errors" (Web only)
- Configure CORS on backend
- Add headers if needed:
  ```dart
  options.headers['Access-Control-Allow-Origin'] = '*';
  ```

---

## Next: Backend Implementation

Your API client is ready! Now you need to create the backend APIs. Choose one:

### Option A: Firebase Cloud Functions (Recommended for Firebase users)
- Fast setup
- Serverless
- Auto-scaling
- Integrated with Firestore

### Option B: Custom REST API
- **Node.js + Express** (easiest)
- **Django + DRF** (Python)
- **Go + Gin** (performant)
- **Rust + Actix** (very fast)

### Option C: Backend-as-a-Service
- **Supabase** (PostgreSQL + REST API)
- **AppWrite** (Open source)
- **Nest.js** (TypeScript)

---

## Summary

✅ **Professional API architecture** ready  
✅ **Type-safe** with DTOs  
✅ **Error handling** built-in  
✅ **Logging & debugging** included  
✅ **Authentication** auto-injected  
✅ **Easy to test** & mock  
✅ **Scalable** for new endpoints  

🎉 **You're ready to build professional APIs!**

For detailed examples, see: `lib/app/modules/example_api_controllers.dart`
For full documentation, see: `API_IMPLEMENTATION_GUIDE.md`
